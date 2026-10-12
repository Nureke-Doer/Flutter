import 'dart:async';

import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_entry.dart';
import '../../domain/repositories/habit_repository.dart';
import '../datasources/demo_habits.dart';

/// Реализация репозитория, хранящая данные в оперативной памяти.
///
/// Неделя 4: временное хранилище. С недели 6 в приложении используется
/// реализация на Hive, а эта осталась для тестов — благодаря интерфейсу
/// [HabitRepository] BLoC не замечает разницы.
class InMemoryHabitRepository implements HabitRepository {
  InMemoryHabitRepository({
    List<Habit>? initial,
    List<HabitEntry> entries = const [],
  }) : _habits = List.of(initial ?? buildDemoHabits()),
       _entries = {for (final e in entries) e.key: e};

  List<Habit> _habits;
  final Map<String, HabitEntry> _entries;
  final _habitsController = StreamController<List<Habit>>.broadcast();
  final _entriesController = StreamController<List<HabitEntry>>.broadcast();

  @override
  Stream<List<Habit>> watchHabits() async* {
    yield List.unmodifiable(_habits);
    yield* _habitsController.stream;
  }

  @override
  Stream<List<HabitEntry>> watchEntries() async* {
    yield List.unmodifiable(_entries.values);
    yield* _entriesController.stream;
  }

  @override
  Future<void> saveHabit(Habit habit) async {
    final index = _habits.indexWhere((h) => h.id == habit.id);
    _habits = [..._habits];
    if (index == -1) {
      _habits.add(habit);
    } else {
      _habits[index] = habit;
    }
    _emitHabits();
  }

  @override
  Future<void> deleteHabit(String id) async {
    _entries.removeWhere((_, e) => e.habitId == id);
    _habits = _habits.where((h) => h.id != id).toList();
    _emitEntries();
    _emitHabits();
  }

  @override
  Future<void> setEntry(String habitId, DateTime day, EntryValue? value) async {
    final key = HabitEntry.keyFor(habitId, day);
    if (value == null) {
      _entries.remove(key);
    } else {
      _entries[key] = HabitEntry(habitId: habitId, date: day, value: value);
    }
    _emitEntries();
  }

  @override
  Future<void> restoreEntries(List<HabitEntry> entries) async {
    for (final e in entries) {
      _entries[e.key] = e;
    }
    _emitEntries();
  }

  void _emitHabits() => _habitsController.add(List.unmodifiable(_habits));

  void _emitEntries() =>
      _entriesController.add(List.unmodifiable(_entries.values));

  Future<void> dispose() async {
    await _habitsController.close();
    await _entriesController.close();
  }
}
