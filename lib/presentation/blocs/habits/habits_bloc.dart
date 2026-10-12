import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/habit.dart';
import '../../../domain/repositories/habit_repository.dart';

part 'habits_event.dart';
part 'habits_state.dart';

/// BLoC основной логики приложения — работа со списком целей.
///
/// UI отправляет события (`add(HabitToggled(...))`), BLoC обращается
/// к [HabitRepository], а новое состояние приходит из потока
/// `watchHabits()`. Так UI не знает, где и как хранятся данные.
class HabitsBloc extends Bloc<HabitsEvent, HabitsState> {
  HabitsBloc({required HabitRepository repository})
    : _repository = repository,
      super(const HabitsState()) {
    on<HabitsSubscriptionRequested>(_onSubscriptionRequested);
    on<HabitToggled>(_onToggled);
    on<HabitSaved>(_onSaved);
    on<HabitDeleted>(_onDeleted);
    on<HabitDeletionUndone>(_onDeletionUndone);
  }

  final HabitRepository _repository;

  Future<void> _onSubscriptionRequested(
    HabitsSubscriptionRequested event,
    Emitter<HabitsState> emit,
  ) async {
    emit(state.copyWith(status: HabitsStatus.loading));
    // emit.forEach слушает поток, пока BLoC жив, и превращает
    // каждое значение в новое состояние.
    await emit.forEach<List<Habit>>(
      _repository.watchHabits(),
      onData: (habits) =>
          state.copyWith(status: HabitsStatus.success, habits: habits),
      onError: (_, _) => state.copyWith(status: HabitsStatus.failure),
    );
  }

  Future<void> _onToggled(HabitToggled event, Emitter<HabitsState> emit) async {
    final habit = state.byId(event.habitId);
    if (habit == null) return;
    await _repository.saveHabit(habit.toggleDay(event.day));
  }

  Future<void> _onSaved(HabitSaved event, Emitter<HabitsState> emit) =>
      _repository.saveHabit(event.habit);

  Future<void> _onDeleted(HabitDeleted event, Emitter<HabitsState> emit) async {
    final habit = state.byId(event.habitId);
    if (habit == null) return;
    emit(state.copyWith(lastDeleted: () => habit));
    await _repository.deleteHabit(event.habitId);
  }

  Future<void> _onDeletionUndone(
    HabitDeletionUndone event,
    Emitter<HabitsState> emit,
  ) async {
    final habit = state.lastDeleted;
    if (habit == null) return;
    emit(state.copyWith(lastDeleted: () => null));
    await _repository.saveHabit(habit);
  }
}
