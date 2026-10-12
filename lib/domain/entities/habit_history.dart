import 'package:equatable/equatable.dart';

import '../../core/utils/date_utils.dart';
import 'habit.dart';
import 'habit_entry.dart';

/// Итоги привычки за один месяц (строка таблицы «по месяцам»).
class MonthSummary extends Equatable {
  const MonthSummary({
    required this.month,
    this.successes = 0,
    this.failures = 0,
    this.skips = 0,
    this.amount = 0,
  });

  /// Первый день месяца.
  final DateTime month;
  final int successes;
  final int failures;
  final int skips;

  /// Сумма для числовых привычек.
  final double amount;

  MonthSummary _add(EntryValue v) => MonthSummary(
    month: month,
    successes: successes + (v.isSuccess ? 1 : 0),
    failures: failures + (v.isFailure ? 1 : 0),
    skips: skips + (v.isNeutral ? 1 : 0),
    amount: amount + v.amount,
  );

  @override
  List<Object?> get props => [month, successes, failures, skips, amount];
}

/// История отметок одной привычки и вся статистика по ней.
///
/// Чистая бизнес-логика без Flutter — легко покрывается unit-тестами.
/// Правила (из ТЗ):
/// - текущая серия прерывается **только** ✘;
/// - 0 (пропуск) и пустые дни серию не прерывают и не увеличивают;
/// - число > 0 считается выполнением.
class HabitHistory extends Equatable {
  HabitHistory([Map<DateTime, EntryValue> values = const {}])
    : _values = {for (final e in values.entries) dateOnly(e.key): e.value};

  factory HabitHistory.fromEntries(Iterable<HabitEntry> entries) =>
      HabitHistory({for (final e in entries) e.date: e.value});

  static final empty = HabitHistory();

  final Map<DateTime, EntryValue> _values;

  /// Отмеченные дни по возрастанию (считается один раз при первом обращении).
  late final List<DateTime> days = _values.keys.toList()..sort();

  bool get isEmpty => _values.isEmpty;

  /// Количество отмеченных дней (записей).
  int get length => _values.length;

  EntryValue? valueOn(DateTime day) => _values[dateOnly(day)];

  bool isSuccessOn(DateTime day) => valueOn(day)?.isSuccess ?? false;

  /// Отметки в виде записей (например, чтобы восстановить после удаления).
  List<HabitEntry> toEntries(String habitId) => [
    for (final day in days)
      HabitEntry(habitId: habitId, date: day, value: _values[day]!),
  ];

  /// Копия истории с новым значением за [day] (`null` — очистить день).
  HabitHistory withValue(DateTime day, EntryValue? value) {
    final copy = {..._values};
    if (value == null) {
      copy.remove(dateOnly(day));
    } else {
      copy[dateOnly(day)] = value;
    }
    return HabitHistory(copy);
  }

  /// Текущая серия: выполненные дни после последнего ✘.
  late final int currentStreak = () {
    var streak = 0;
    for (final day in days.reversed) {
      final v = _values[day]!;
      if (v.isFailure) break;
      if (v.isSuccess) streak++;
    }
    return streak;
  }();

  /// Лучшая серия за всё время.
  late final int bestStreak = () {
    var best = 0;
    var run = 0;
    for (final day in days) {
      final v = _values[day]!;
      if (v.isFailure) {
        run = 0;
      } else if (v.isSuccess) {
        run++;
        if (run > best) best = run;
      }
    }
    return best;
  }();

  /// Всего дней выполнения.
  late final int successCount = _values.values.where((v) => v.isSuccess).length;

  /// Всего срывов / невыполнений.
  late final int failureCount = _values.values.where((v) => v.isFailure).length;

  /// Сумма для числовых привычек.
  late final double totalAmount = _values.values.fold(
    0,
    (sum, v) => sum + v.amount,
  );

  /// Сумма значений и количество выполнений, начиная с [from] (включительно).
  double amountSince(DateTime from) => _sumSince(from, (v) => v.amount);

  int successesSince(DateTime from) =>
      _sumSince(from, (v) => v.isSuccess ? 1 : 0).toInt();

  double _sumSince(DateTime from, double Function(EntryValue) f) {
    final start = dateOnly(from);
    var sum = 0.0;
    _values.forEach((day, v) {
      if (!day.isBefore(start)) sum += f(v);
    });
    return sum;
  }

  /// Сколько раз привычка выполнена на неделе, в которую входит [day].
  int successesInWeek(DateTime day) {
    final monday = startOfWeek(day);
    var count = 0;
    for (var i = 0; i < 7; i++) {
      if (isSuccessOn(addDays(monday, i))) count++;
    }
    return count;
  }

  /// Итоги по месяцам — от новых к старым.
  late final List<MonthSummary> monthly = () {
    final byMonth = <DateTime, MonthSummary>{};
    for (final day in days) {
      final month = startOfMonth(day);
      byMonth[month] = (byMonth[month] ?? MonthSummary(month: month))._add(
        _values[day]!,
      );
    }
    return byMonth.values.toList()..sort((a, b) => b.month.compareTo(a.month));
  }();

  /// Доля выполнения привычки за последние [days] дней (0.0–1.0).
  ///
  /// - «каждый день» / «дни недели»: выполненные / запланированные дни;
  ///   пропуски (0) не учитываются, а сегодняшний день — только если
  ///   уже отмечен (утром процент не «проседает»);
  /// - «N раз в неделю»: выполнения / (N × недель в периоде), не больше 100%.
  double completionRate(Habit habit, DateTime today, {int days = 7}) {
    final start = dateOnly(habit.createdAt);
    final window = lastDays(today, days).where((d) => !d.isBefore(start));
    if (window.isEmpty) return 0;

    if (habit.schedule.type == ScheduleType.timesPerWeek) {
      final done = window.where(isSuccessOn).length;
      final planned = habit.schedule.timesPerWeek * window.length / 7;
      return planned == 0 ? 0 : (done / planned).clamp(0, 1).toDouble();
    }

    var planned = 0;
    var done = 0;
    for (final day in window) {
      if (!habit.isScheduledOn(day)) continue;
      final v = valueOn(day);
      if (v != null && v.isNeutral) continue;
      if (isSameDay(day, today) && v == null) continue;
      planned++;
      if (v?.isSuccess ?? false) done++;
    }
    return planned == 0 ? 0 : done / planned;
  }

  @override
  List<Object?> get props => [_values];
}
