import '../utils/date_utils.dart';

/// Тип цели: обычная привычка или учебная цель.
enum HabitType { habit, study }

/// Набор иконок, которые можно выбрать для цели.
/// Модель не зависит от Flutter, поэтому храним только ключ,
/// а саму `IconData` подбираем в слое UI (см. `widgets/habit_visuals.dart`).
enum HabitIcon {
  check,
  water,
  run,
  book,
  code,
  language,
  math,
  meditation,
  sleep,
  music,
  science,
  art,
}

/// Привычка или учебная цель.
class Habit {
  const Habit({
    required this.id,
    required this.title,
    required this.createdAt,
    this.description = '',
    this.type = HabitType.habit,
    this.icon = HabitIcon.check,
    this.colorValue = 0xFF00897B,
    this.weekdays = allWeekdays,
    this.reminderMinutes,
    this.targetMinutes,
    this.completedDays = const {},
  });

  static const Set<int> allWeekdays = {1, 2, 3, 4, 5, 6, 7};

  final String id;
  final String title;
  final String description;
  final HabitType type;
  final HabitIcon icon;

  /// Цвет в формате ARGB (например, 0xFF00897B).
  final int colorValue;

  /// Дни недели, в которые цель запланирована: 1 — понедельник … 7 — воскресенье.
  final Set<int> weekdays;

  /// Время напоминания в минутах от начала суток (например, 9:30 → 570).
  final int? reminderMinutes;

  /// Для учебных целей — сколько минут в день заниматься.
  final int? targetMinutes;

  /// Дни, в которые цель была выполнена (только дата, без времени).
  final Set<DateTime> completedDays;

  final DateTime createdAt;

  bool get isEveryDay => weekdays.length == 7;

  bool isScheduledOn(DateTime day) => weekdays.contains(day.weekday);

  bool isCompletedOn(DateTime day) => completedDays.contains(dateOnly(day));

  /// Текущая серия: сколько запланированных дней подряд цель выполнялась.
  ///
  /// Незапланированные дни пропускаются и серию не прерывают.
  /// Сегодняшний день, если он ещё не отмечен, тоже не прерывает серию —
  /// день ещё не закончился.
  int currentStreak(DateTime today) {
    final start = dateOnly(createdAt);
    var cursor = dateOnly(today);
    var streak = 0;
    while (!cursor.isBefore(start)) {
      if (isScheduledOn(cursor)) {
        if (isCompletedOn(cursor)) {
          streak++;
        } else if (!isSameDay(cursor, today)) {
          break;
        }
      }
      cursor = addDays(cursor, -1);
    }
    return streak;
  }

  /// Лучшая (самая длинная) серия за всё время.
  int bestStreak(DateTime today) {
    var best = 0;
    var run = 0;
    var cursor = dateOnly(createdAt);
    final end = dateOnly(today);
    while (!cursor.isAfter(end)) {
      if (isScheduledOn(cursor)) {
        if (isCompletedOn(cursor)) {
          run++;
          if (run > best) best = run;
        } else if (!isSameDay(cursor, end)) {
          run = 0;
        }
      }
      cursor = addDays(cursor, 1);
    }
    return best;
  }

  /// Доля выполненных запланированных дней за последние [days] дней (0.0–1.0).
  ///
  /// Сегодняшний день учитывается, только если уже выполнен,
  /// чтобы утром процент не «проседал».
  double completionRate(DateTime today, {int days = 7}) {
    final start = dateOnly(createdAt);
    var planned = 0;
    var done = 0;
    for (final day in lastDays(today, days)) {
      if (day.isBefore(start) || !isScheduledOn(day)) continue;
      final completed = isCompletedOn(day);
      if (isSameDay(day, today) && !completed) continue;
      planned++;
      if (completed) done++;
    }
    return planned == 0 ? 0 : done / planned;
  }

  Habit copyWith({
    String? title,
    String? description,
    HabitType? type,
    HabitIcon? icon,
    int? colorValue,
    Set<int>? weekdays,
    int? Function()? reminderMinutes,
    int? Function()? targetMinutes,
    Set<DateTime>? completedDays,
  }) {
    return Habit(
      id: id,
      createdAt: createdAt,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      colorValue: colorValue ?? this.colorValue,
      weekdays: weekdays ?? this.weekdays,
      reminderMinutes: reminderMinutes != null
          ? reminderMinutes()
          : this.reminderMinutes,
      targetMinutes: targetMinutes != null
          ? targetMinutes()
          : this.targetMinutes,
      completedDays: completedDays ?? this.completedDays,
    );
  }
}
