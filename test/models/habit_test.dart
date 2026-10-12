import 'package:flutter_test/flutter_test.dart';
import 'package:habit_study_tracker/models/habit.dart';
import 'package:habit_study_tracker/utils/date_utils.dart';

void main() {
  // Среда, 9 сентября 2026.
  final today = DateTime(2026, 9, 9);
  DateTime ago(int days) => addDays(today, -days);

  Habit habit({
    Set<DateTime> done = const {},
    Set<int> weekdays = Habit.allWeekdays,
    int createdDaysAgo = 30,
  }) => Habit(
    id: '1',
    title: 'Тест',
    createdAt: ago(createdDaysAgo),
    weekdays: weekdays,
    completedDays: done,
  );

  group('currentStreak', () {
    test('считает подряд идущие дни, включая сегодня', () {
      expect(
        habit(done: {ago(0), ago(1), ago(2), ago(4)}).currentStreak(today),
        3,
      );
    });

    test('невыполненный сегодняшний день не обнуляет серию', () {
      expect(habit(done: {ago(1), ago(2)}).currentStreak(today), 2);
    });

    test('пропуск вчерашнего дня обнуляет серию', () {
      expect(habit(done: {ago(2), ago(3)}).currentStreak(today), 0);
    });

    test('незапланированные дни не прерывают серию', () {
      // Только Пн/Ср/Пт. Сегодня среда (09.09), понедельник — 07.09, пятница — 04.09.
      final h = habit(weekdays: {1, 3, 5}, done: {ago(0), ago(2), ago(5)});
      expect(h.currentStreak(today), 3);
    });

    test('не уходит раньше даты создания', () {
      final h = habit(createdDaysAgo: 1, done: {ago(0), ago(1), ago(2)});
      expect(h.currentStreak(today), 2);
    });
  });

  group('bestStreak', () {
    test('находит самую длинную серию', () {
      final h = habit(done: {ago(10), ago(9), ago(8), ago(7), ago(2), ago(1)});
      expect(h.bestStreak(today), 4);
    });
  });

  group('completionRate', () {
    test('считает долю выполненных дней за неделю', () {
      // Выполнено 3 из 6 прошедших дней; сегодняшний не отмечен и не учитывается.
      final h = habit(done: {ago(1), ago(2), ago(3)});
      expect(h.completionRate(today), closeTo(0.5, 0.001));
    });

    test('возвращает 0 без запланированных дней', () {
      expect(habit(createdDaysAgo: 0).completionRate(today), 0);
    });
  });

  test('copyWith позволяет обнулить напоминание', () {
    final h = Habit(
      id: '1',
      title: 'A',
      createdAt: today,
      reminderMinutes: 600,
    );
    expect(h.copyWith(reminderMinutes: () => null).reminderMinutes, isNull);
    expect(h.copyWith(title: 'B').reminderMinutes, 600);
  });
}
