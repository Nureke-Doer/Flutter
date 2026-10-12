import 'dart:convert';

import 'package:hive_ce/hive.dart';

import '../../domain/entities/habit.dart';
import '../../domain/repositories/habit_repository.dart';
import '../datasources/demo_habits.dart';
import '../models/habit_model.dart';

/// Реализация [HabitRepository] на Hive — цели сохраняются между запусками
/// и доступны без интернета.
///
/// Заменила `InMemoryHabitRepository` (неделя 4) — BLoC и UI не изменились,
/// поменялась только регистрация в DI.
class HiveHabitRepository implements HabitRepository {
  HiveHabitRepository({
    required Box<String> habitsBox,
    required Box<String> metaBox,
  }) : _box = habitsBox,
       _meta = metaBox;

  static const _seededKey = 'demo_seeded';

  final Box<String> _box;
  final Box<String> _meta;

  /// При самом первом запуске добавляет демо-цели, чтобы приложение
  /// не было пустым. Если пользователь всё удалит — повторно не добавляются.
  Future<void> seedIfNeeded() async {
    if (_meta.get(_seededKey) != null) return;
    if (_box.isEmpty) {
      for (final habit in buildDemoHabits()) {
        await saveHabit(habit);
      }
    }
    await _meta.put(_seededKey, DateTime.now().toIso8601String());
  }

  List<Habit> _readAll() {
    final habits = <Habit>[];
    for (final raw in _box.values) {
      try {
        habits.add(
          HabitModel.fromJson(
            jsonDecode(raw) as Map<String, dynamic>,
          ).toEntity(),
        );
      } on Object {
        // Повреждённая запись не должна ломать весь список.
        continue;
      }
    }
    habits.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return List.unmodifiable(habits);
  }

  @override
  Stream<List<Habit>> watchHabits() async* {
    yield _readAll();
    // box.watch() сообщает о каждом изменении коробки.
    yield* _box.watch().map((_) => _readAll());
  }

  @override
  Future<void> saveHabit(Habit habit) =>
      _box.put(habit.id, jsonEncode(HabitModel.fromEntity(habit).toJson()));

  @override
  Future<void> deleteHabit(String id) => _box.delete(id);
}
