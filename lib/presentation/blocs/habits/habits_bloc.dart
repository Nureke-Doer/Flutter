import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/habit.dart';
import '../../../domain/entities/habit_entry.dart';
import '../../../domain/entities/habit_history.dart';
import '../../../domain/repositories/habit_repository.dart';

part 'habits_event.dart';
part 'habits_state.dart';

/// BLoC основной логики приложения — привычки и ежедневные отметки.
///
/// UI отправляет события (`add(HabitEntrySet(...))`), BLoC обращается
/// к [HabitRepository], а новое состояние приходит из потоков
/// `watchHabits()` и `watchEntries()`. Так UI не знает, где и как
/// хранятся данные.
class HabitsBloc extends Bloc<HabitsEvent, HabitsState> {
  HabitsBloc({required HabitRepository repository})
    : _repository = repository,
      super(const HabitsState()) {
    on<HabitsSubscriptionRequested>(_onSubscriptionRequested);
    on<HabitQuickToggled>(_onQuickToggled);
    on<HabitEntrySet>(_onEntrySet);
    on<HabitSaved>(_onSaved);
    on<HabitArchiveToggled>(_onArchiveToggled);
    on<HabitDeleted>(_onDeleted);
    on<HabitDeletionUndone>(_onDeletionUndone);
  }

  final HabitRepository _repository;

  Future<void> _onSubscriptionRequested(
    HabitsSubscriptionRequested event,
    Emitter<HabitsState> emit,
  ) async {
    emit(state.copyWith(status: HabitsStatus.loading));
    // Слушаем два потока параллельно. emit.forEach работает, пока BLoC жив,
    // и превращает каждое значение потока в новое состояние.
    await Future.wait([
      emit.forEach<List<Habit>>(
        _repository.watchHabits(),
        onData: (habits) =>
            state.copyWith(status: HabitsStatus.success, habits: habits),
        onError: (_, _) => state.copyWith(status: HabitsStatus.failure),
      ),
      emit.forEach<List<HabitEntry>>(
        _repository.watchEntries(),
        onData: (entries) => state.copyWith(histories: _group(entries)),
        onError: (_, _) => state.copyWith(status: HabitsStatus.failure),
      ),
    ]);
  }

  /// Группирует плоский список отметок по привычкам.
  static Map<String, HabitHistory> _group(List<HabitEntry> entries) {
    final byHabit = <String, Map<DateTime, EntryValue>>{};
    for (final e in entries) {
      (byHabit[e.habitId] ??= {})[e.date] = e.value;
    }
    return {for (final e in byHabit.entries) e.key: HabitHistory(e.value)};
  }

  Future<void> _onQuickToggled(
    HabitQuickToggled event,
    Emitter<HabitsState> emit,
  ) async {
    final habit = state.byId(event.habitId);
    if (habit == null) return;
    final current = state.historyOf(habit.id).valueOn(event.day);
    final EntryValue? next = (current?.isSuccess ?? false)
        ? null
        : habit.isNumeric
        ? EntryAmount(habit.target ?? 1)
        : const EntryDone();
    await _repository.setEntry(habit.id, event.day, next);
  }

  Future<void> _onEntrySet(HabitEntrySet event, Emitter<HabitsState> emit) {
    return _repository.setEntry(event.habitId, event.day, event.value);
  }

  Future<void> _onSaved(HabitSaved event, Emitter<HabitsState> emit) =>
      _repository.saveHabit(event.habit);

  Future<void> _onArchiveToggled(
    HabitArchiveToggled event,
    Emitter<HabitsState> emit,
  ) async {
    final habit = state.byId(event.habitId);
    if (habit == null) return;
    await _repository.saveHabit(habit.copyWith(archived: !habit.archived));
  }

  Future<void> _onDeleted(HabitDeleted event, Emitter<HabitsState> emit) async {
    final habit = state.byId(event.habitId);
    if (habit == null) return;
    emit(
      state.copyWith(
        lastDeleted: () => habit,
        lastDeletedEntries: state.historyOf(habit.id).toEntries(habit.id),
      ),
    );
    await _repository.deleteHabit(event.habitId);
  }

  Future<void> _onDeletionUndone(
    HabitDeletionUndone event,
    Emitter<HabitsState> emit,
  ) async {
    final habit = state.lastDeleted;
    if (habit == null) return;
    final entries = state.lastDeletedEntries;
    emit(state.copyWith(lastDeleted: () => null, lastDeletedEntries: const []));
    await _repository.saveHabit(habit);
    await _repository.restoreEntries(entries);
  }
}
