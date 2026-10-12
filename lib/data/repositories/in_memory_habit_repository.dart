import 'dart:async';

import '../../domain/entities/habit.dart';
import '../../domain/repositories/habit_repository.dart';
import '../datasources/demo_habits.dart';

/// Реализация репозитория, хранящая данные в оперативной памяти.
///
/// Неделя 4: временное хранилище. На неделе 6 будет заменено реализацией
/// на Hive — благодаря интерфейсу [HabitRepository] остальной код
/// менять не придётся, достаточно поменять регистрацию в DI.
class InMemoryHabitRepository implements HabitRepository {
  InMemoryHabitRepository({List<Habit>? initial})
    : _habits = List.of(initial ?? buildDemoHabits());

  List<Habit> _habits;
  final _controller = StreamController<List<Habit>>.broadcast();

  @override
  Stream<List<Habit>> watchHabits() async* {
    yield List.unmodifiable(_habits);
    yield* _controller.stream;
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
    _emit();
  }

  @override
  Future<void> deleteHabit(String id) async {
    _habits = _habits.where((h) => h.id != id).toList();
    _emit();
  }

  void _emit() => _controller.add(List.unmodifiable(_habits));

  Future<void> dispose() => _controller.close();
}
