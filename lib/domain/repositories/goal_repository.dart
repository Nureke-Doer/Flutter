import '../entities/study_goal.dart';

/// Учебные цели.
abstract interface class GoalRepository {
  Stream<List<StudyGoal>> watchGoals();

  Future<void> saveGoal(StudyGoal goal);

  Future<void> deleteGoal(String id);
}
