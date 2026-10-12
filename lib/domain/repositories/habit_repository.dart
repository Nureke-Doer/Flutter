import '../entities/habit.dart';

/// Контракт репозитория целей (паттерн Repository).
///
/// Доменный слой и BLoC знают только об этом интерфейсе и не знают,
/// где хранятся данные: в памяти, в Hive или в Firestore.
/// Реализации находятся в слое `data`.
abstract interface class HabitRepository {
  /// Поток с актуальным списком целей. Сразу отдаёт текущее значение,
  /// затем — новое значение после каждого изменения.
  Stream<List<Habit>> watchHabits();

  /// Создаёт цель или обновляет существующую (по `id`).
  Future<void> saveHabit(Habit habit);

  /// Удаляет цель по `id`.
  Future<void> deleteHabit(String id);
}
