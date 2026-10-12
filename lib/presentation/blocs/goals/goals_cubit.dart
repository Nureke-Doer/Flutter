import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/study_goal.dart';
import '../../../domain/repositories/goal_repository.dart';

/// Учебные цели. Прогресс считается в UI через `GoalProgress`
/// из актуальных привычек и отметок (`HabitsBloc`).
class GoalsCubit extends Cubit<List<StudyGoal>> {
  GoalsCubit({required GoalRepository repository})
    : _repository = repository,
      super(const []) {
    _subscription = _repository.watchGoals().listen(emit);
  }

  final GoalRepository _repository;
  late final StreamSubscription<List<StudyGoal>> _subscription;

  StudyGoal? byId(String id) {
    for (final g in state) {
      if (g.id == id) return g;
    }
    return null;
  }

  Future<void> save(StudyGoal goal) => _repository.saveGoal(goal);

  Future<void> delete(String id) => _repository.deleteGoal(id);

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
