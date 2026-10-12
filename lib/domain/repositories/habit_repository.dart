import '../entities/habit.dart';
import '../entities/habit_entry.dart';

/// Контракт репозитория привычек и их отметок (паттерн Repository).
///
/// Доменный слой и BLoC знают только об этом интерфейсе и не знают,
/// где хранятся данные: в памяти, в Hive или в Firestore.
/// Реализации находятся в слое `data`.
abstract interface class HabitRepository {
  /// Поток с актуальным списком привычек (включая архивные). Сразу отдаёт
  /// текущее значение, затем — новое значение после каждого изменения.
  Stream<List<Habit>> watchHabits();

  /// Поток со всеми отметками всех привычек.
  Stream<List<HabitEntry>> watchEntries();

  /// Создаёт привычку или обновляет существующую (по `id`).
  Future<void> saveHabit(Habit habit);

  /// Удаляет привычку вместе с её историей.
  Future<void> deleteHabit(String id);

  /// Записывает отметку за день; `value == null` — очистить день («пусто»).
  Future<void> setEntry(String habitId, DateTime day, EntryValue? value);

  /// Восстанавливает несколько отметок разом (отмена удаления привычки).
  Future<void> restoreEntries(List<HabitEntry> entries);
}
