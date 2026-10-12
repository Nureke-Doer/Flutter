import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_entry.dart';
import '../../domain/repositories/habit_repository.dart';
import '../datasources/local/local_collection.dart';
import '../models/habit_entry_model.dart';
import '../models/habit_model.dart';

/// Реализация [HabitRepository] на Hive — привычки и отметки сохраняются
/// между запусками и доступны без интернета.
///
/// Привычки и отметки лежат в разных коллекциях: отметка за день —
/// маленький отдельный документ, поэтому нажатие ✔ не перезаписывает
/// всю привычку (это важно и для синхронизации с Firestore).
class HiveHabitRepository implements HabitRepository {
  HiveHabitRepository({
    required LocalCollection habits,
    required LocalCollection entries,
  }) : _habits = habits,
       _entries = entries;

  final LocalCollection _habits;
  final LocalCollection _entries;

  static List<Habit> _toHabits(List<Map<String, dynamic>> raw) {
    final habits = <Habit>[];
    for (final json in raw) {
      try {
        habits.add(HabitModel.fromJson(json).toEntity());
      } on Object {
        // Повреждённая запись не должна ломать весь список.
        continue;
      }
    }
    habits.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return List.unmodifiable(habits);
  }

  static List<HabitEntry> _toEntries(List<Map<String, dynamic>> raw) {
    final entries = <HabitEntry>[];
    for (final json in raw) {
      try {
        final entry = HabitEntryModel.fromJson(json).toEntity();
        if (entry != null) entries.add(entry);
      } on Object {
        continue;
      }
    }
    return List.unmodifiable(entries);
  }

  @override
  Stream<List<Habit>> watchHabits() => _habits.watch().map(_toHabits);

  @override
  Stream<List<HabitEntry>> watchEntries() => _entries.watch().map(_toEntries);

  @override
  Future<void> saveHabit(Habit habit) =>
      _habits.put(habit.id, HabitModel.fromEntity(habit).toJson());

  @override
  Future<void> deleteHabit(String id) async {
    await _entries.deleteWhere((json) => json['habitId'] == id);
    await _habits.delete(id);
  }

  @override
  Future<void> setEntry(String habitId, DateTime day, EntryValue? value) {
    final key = HabitEntry.keyFor(habitId, day);
    if (value == null) return _entries.delete(key);
    final entry = HabitEntry(habitId: habitId, date: day, value: value);
    return _entries.put(key, HabitEntryModel.fromEntity(entry).toJson());
  }

  @override
  Future<void> restoreEntries(List<HabitEntry> entries) => _entries.putAll({
    for (final e in entries) e.key: HabitEntryModel.fromEntity(e).toJson(),
  });
}
