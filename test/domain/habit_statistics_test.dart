import 'package:flutter_test/flutter_test.dart';
import 'package:habit_study_tracker/core/utils/date_utils.dart';
import 'package:habit_study_tracker/domain/entities/habit.dart';
import 'package:habit_study_tracker/domain/services/habit_statistics.dart';

void main() {
  final today = DateTime(2026, 9, 9);
  DateTime ago(int d) => addDays(today, -d);

  test('пустой список даёт нулевую статистику', () {
    final stats = HabitStatistics.from(const [], today);
    expect(stats.weekRate, 0);
    expect(stats.totalCheckIns, 0);
    expect(stats.days.length, 7);
    expect(stats.dailyRates, everyElement(0.0));
  });

  test('считает дневные проценты, отметки и лидеров', () {
    final a = Habit(
      id: 'a',
      title: 'A',
      createdAt: ago(10),
      completedDays: {ago(0), ago(1), ago(2)},
    );
    final b = Habit(
      id: 'b',
      title: 'B',
      createdAt: ago(10),
      completedDays: {ago(1)},
    );
    final stats = HabitStatistics.from([b, a], today);

    expect(stats.totalCheckIns, 4);
    expect(stats.activeCount, 2);
    expect(stats.dailyRates.last, 0.5); // сегодня выполнена 1 из 2
    expect(stats.dailyRates[5], 1.0); // вчера — обе
    expect(stats.topByStreak.first.id, 'a');
  });
}
