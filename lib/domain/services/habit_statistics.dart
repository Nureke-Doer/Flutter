import 'package:equatable/equatable.dart';

import '../../core/utils/date_utils.dart';
import '../entities/habit.dart';

/// Сводная статистика по списку целей (чистая бизнес-логика, без UI).
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
  factory HabitStatistics.from(
    List<Habit> habits,
    DateTime today, {
    int period = 7,
  }) {
    final days = lastDays(today, period);
    final dailyRates = days.map((day) {
      final planned = habits
          .where(
            (h) => h.isScheduledOn(day) && !day.isBefore(dateOnly(h.createdAt)),
          )
          .toList();
      if (planned.isEmpty) return 0.0;
      return planned.where((h) => h.isCompletedOn(day)).length / planned.length;
    }).toList();

    final weekRate = habits.isEmpty
        ? 0.0
        : habits
                  .map((h) => h.completionRate(today, days: period))
                  .reduce((a, b) => a + b) /
              habits.length;

    final top = [
      ...habits,
    ]..sort((a, b) => b.currentStreak(today).compareTo(a.currentStreak(today)));

    return HabitStatistics(
      days: days,
      dailyRates: dailyRates,
      weekRate: weekRate,
      totalCheckIns: habits.fold(0, (sum, h) => sum + h.completedDays.length),
      activeCount: habits.length,
      topByStreak: top.take(5).toList(),
    );
  }

  final List<DateTime> days;

  /// Доля выполненных целей за каждый день из [days] (0.0–1.0).
  final List<double> dailyRates;

  /// Средний процент выполнения целей за период.
  final double weekRate;
  final int totalCheckIns;
  final int activeCount;

  /// До 5 целей с самой длинной текущей серией.
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
