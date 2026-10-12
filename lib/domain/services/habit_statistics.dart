import 'package:equatable/equatable.dart';

import '../../core/utils/date_utils.dart';
import '../entities/habit.dart';
import '../entities/habit_history.dart';

/// Сводная статистика по списку привычек (чистая бизнес-логика, без UI).
class HabitStatistics extends Equatable {
  const HabitStatistics({
    required this.days,
    required this.dailyRates,
    required this.weekRate,
    required this.totalCheckIns,
    required this.activeCount,
    required this.topByStreak,
  });

  /// Считает статистику на дату [today] за последние [period] дней.
  /// Архивные привычки не учитываются.
  factory HabitStatistics.from(
    List<Habit> allHabits,
    Map<String, HabitHistory> histories,
    DateTime today, {
    int period = 7,
  }) {
    final habits = allHabits.where((h) => !h.archived).toList();
    HabitHistory historyOf(Habit h) => histories[h.id] ?? HabitHistory.empty;

    final days = lastDays(today, period);
    final dailyRates = days.map((day) {
      var planned = 0;
      var done = 0;
      for (final h in habits) {
        if (day.isBefore(dateOnly(h.createdAt)) || !h.isScheduledOn(day)) {
          continue;
        }
        final value = historyOf(h).valueOn(day);
        // Пропуск (0) ни на что не влияет; «N раз в неделю» учитываем
        // только в дни, когда привычка отмечена.
        if (value != null && value.isNeutral) continue;
        if (h.schedule.type == ScheduleType.timesPerWeek && value == null) {
          continue;
        }
        planned++;
        if (value?.isSuccess ?? false) done++;
      }
      return planned == 0 ? 0.0 : done / planned;
    }).toList();

    final weekRate = habits.isEmpty
        ? 0.0
        : habits
                  .map(
                    (h) => historyOf(h).completionRate(h, today, days: period),
                  )
                  .reduce((a, b) => a + b) /
              habits.length;

    final top = [...habits]
      ..sort(
        (a, b) =>
            historyOf(b).currentStreak.compareTo(historyOf(a).currentStreak),
      );

    return HabitStatistics(
      days: days,
      dailyRates: dailyRates,
      weekRate: weekRate,
      totalCheckIns: habits.fold(
        0,
        (sum, h) => sum + historyOf(h).successCount,
      ),
      activeCount: habits.length,
      topByStreak: top.take(5).toList(),
    );
  }

  final List<DateTime> days;

  /// Доля выполненных привычек за каждый день из [days] (0.0–1.0).
  final List<double> dailyRates;

  /// Средний процент выполнения привычек за период.
  final double weekRate;

  /// Всего дней выполнения по всем привычкам.
  final int totalCheckIns;
  final int activeCount;

  /// До 5 привычек с самой длинной текущей серией.
  final List<Habit> topByStreak;

  @override
  List<Object?> get props => [
    days,
    dailyRates,
    weekRate,
    totalCheckIns,
    activeCount,
    topByStreak,
  ];
}
