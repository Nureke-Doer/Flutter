import 'package:equatable/equatable.dart';

import '../../core/utils/date_utils.dart';
import '../entities/habit.dart';
import '../entities/habit_history.dart';
import '../entities/study_goal.dart';

/// Прогресс учебной цели на дату [today].
///
/// Прогресс = ручная поправка + вклад привязанных привычек с даты
/// создания цели:
/// - числовая привычка добавляет сумму значений (страницы, минуты);
/// - обычная привычка или отказ от вредного — по 1 за каждый ✔.
class GoalProgress extends Equatable {
  const GoalProgress({
    required this.goal,
    required this.current,
    required this.daysLeft,
  });

  factory GoalProgress.calculate({
    required StudyGoal goal,
    required List<Habit> habits,
    required Map<String, HabitHistory> histories,
    required DateTime today,
  }) {
    var current = goal.manualProgress;
    for (final habit in habits) {
      if (!goal.linkedHabitIds.contains(habit.id)) continue;
      current += contribution(
        goal,
        habit,
        histories[habit.id] ?? HabitHistory.empty,
      );
    }
    final daysLeft = daysBetween(today, goal.deadline);
    return GoalProgress(goal: goal, current: current, daysLeft: daysLeft);
  }

  /// Вклад одной привычки в цель с даты создания цели.
  static double contribution(
    StudyGoal goal,
    Habit habit,
    HabitHistory history,
  ) => habit.isNumeric
      ? history.amountSince(goal.createdAt)
      : history.successesSince(goal.createdAt).toDouble();

  final StudyGoal goal;

  /// Сколько уже сделано.
  final double current;

  /// Дней до дедлайна (0 — сегодня, < 0 — просрочено).
  final int daysLeft;

  /// Доля выполнения 0.0–1.0.
  double get fraction =>
      goal.target <= 0 ? 0 : (current / goal.target).clamp(0, 1).toDouble();

  double get remaining =>
      (goal.target - current).clamp(0, double.infinity).toDouble();

  bool get isCompleted => current >= goal.target;

  bool get isOverdue => !isCompleted && daysLeft < 0;

  /// Сколько нужно делать в день, чтобы успеть к дедлайну
  /// (сегодняшний день тоже считается). `null`, если цель выполнена
  /// или дедлайн прошёл.
  double? get neededPerDay {
    if (isCompleted || daysLeft < 0) return null;
    return remaining / (daysLeft + 1);
  }

  @override
  List<Object?> get props => [goal, current, daysLeft];
}
