import '../../domain/entities/study_goal.dart';
import '../../domain/repositories/goal_repository.dart';
import '../datasources/local/local_collection.dart';
import '../models/study_goal_model.dart';

/// Учебные цели в Hive.
class HiveGoalRepository implements GoalRepository {
  HiveGoalRepository(this._collection);

  final LocalCollection _collection;

  static List<StudyGoal> _map(List<Map<String, dynamic>> raw) {
    final list = <StudyGoal>[];
    for (final json in raw) {
      try {
        list.add(StudyGoalModel.fromJson(json).toEntity());
      } on Object {
        continue;
      }
    }
    list.sort((a, b) => a.deadline.compareTo(b.deadline));
    return List.unmodifiable(list);
  }

  @override
  Stream<List<StudyGoal>> watchGoals() => _collection.watch().map(_map);

  @override
  Future<void> saveGoal(StudyGoal goal) =>
      _collection.put(goal.id, StudyGoalModel.fromEntity(goal).toJson());

  @override
  Future<void> deleteGoal(String id) => _collection.delete(id);
}
