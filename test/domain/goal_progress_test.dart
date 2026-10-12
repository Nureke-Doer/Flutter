import 'package:flutter_test/flutter_test.dart';
import 'package:habit_study_tracker/core/utils/date_utils.dart';
import 'package:habit_study_tracker/domain/entities/habit.dart';
import 'package:habit_study_tracker/domain/entities/habit_entry.dart';
import 'package:habit_study_tracker/domain/entities/habit_history.dart';
import 'package:habit_study_tracker/domain/entities/study_goal.dart';
import 'package:habit_study_tracker/domain/services/goal_progress.dart';

void main() {
  final today = DateTime(2026, 9, 9);
  DateTime ago(int d) => addDays(today, -d);

  final reading = Habit(
    id: 'reading',
    title: 'Чтение',
    kind: HabitKind.numeric,
    unit: 'стр.',
    createdAt: ago(30),
  );
  final practice = Habit(id: 'practice', title: 'Задачи', createdAt: ago(30));
  final histories = {
    'reading': HabitHistory({
      ago(10): const EntryAmount(100), // до начала цели — не считается
      ago(2): const EntryAmount(30),
      ago(1): const EntryAmount(20),
    }),
    'practice': HabitHistory({
      ago(1): const EntryDone(),
      ago(0): const EntryDone(),
      ago(3): const EntryFailed(),
    }),
  };

  StudyGoal goal({
    Set<String> linked = const {'reading'},
    double target = 300,
    double manual = 0,
    int deadlineIn = 10,
  }) => StudyGoal(
    id: 'g',
    title: 'Прочитать 300 страниц',
    target: target,
    unit: 'стр.',
    deadline: addDays(today, deadlineIn),
    createdAt: ago(5),
    linkedHabitIds: linked,
    manualProgress: manual,
  );

  GoalProgress calc(StudyGoal g) => GoalProgress.calculate(
    goal: g,
    habits: [reading, practice],
    histories: histories,
    today: today,
  );

  test('числовая привычка добавляет сумму с даты создания цели', () {
    final p = calc(goal(manual: 40));
    expect(p.current, 90);
    expect(p.fraction, closeTo(0.3, 0.001));
    expect(p.remaining, 210);
    expect(p.daysLeft, 10);
    // 210 страниц за 11 дней (включая сегодня).
    expect(p.neededPerDay, closeTo(210 / 11, 0.001));
  });

  test('обычная привычка добавляет по 1 за каждый ✔', () {
    final p = calc(goal(linked: {'practice'}, target: 10));
    expect(p.current, 2);
  });

  test('без привязанных привычек — только ручной прогресс', () {
    expect(calc(goal(linked: {}, manual: 15)).current, 15);
  });

  test('выполненная цель и просрочка', () {
    final done = calc(goal(target: 50));
    expect(done.isCompleted, isTrue);
    expect(done.fraction, 1);
    expect(done.neededPerDay, isNull);

    final overdue = calc(goal(deadlineIn: -1));
    expect(overdue.isOverdue, isTrue);
    expect(overdue.neededPerDay, isNull);
  });
}
