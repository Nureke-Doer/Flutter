part of 'habits_bloc.dart';

enum HabitsStatus { initial, loading, success, failure }

/// Состояние привычек и их историй. Неизменяемое: новое состояние
/// создаётся через [copyWith], а `Equatable` позволяет BLoC не
/// перерисовывать UI, если состояние не изменилось.
final class HabitsState extends Equatable {
  const HabitsState({
    this.status = HabitsStatus.initial,
    this.habits = const [],
    this.histories = const {},
    this.lastDeleted,
    this.lastDeletedEntries = const [],
  });

  final HabitsStatus status;

  /// Все привычки, включая архивные.
  final List<Habit> habits;

  /// История отметок по id привычки.
  final Map<String, HabitHistory> histories;

  /// Последняя удалённая привычка и её отметки — для отмены удаления.
  final Habit? lastDeleted;
  final List<HabitEntry> lastDeletedEntries;

  /// Привычки, которые не в архиве.
  List<Habit> get activeHabits => habits.where((h) => !h.archived).toList();

  Habit? byId(String id) {
    for (final h in habits) {
      if (h.id == id) return h;
    }
    return null;
  }

  HabitHistory historyOf(String habitId) =>
      histories[habitId] ?? HabitHistory.empty;

  HabitsState copyWith({
    HabitsStatus? status,
    List<Habit>? habits,
    Map<String, HabitHistory>? histories,
    Habit? Function()? lastDeleted,
    List<HabitEntry>? lastDeletedEntries,
  }) {
    return HabitsState(
      status: status ?? this.status,
      habits: habits ?? this.habits,
      histories: histories ?? this.histories,
      lastDeleted: lastDeleted != null ? lastDeleted() : this.lastDeleted,
      lastDeletedEntries: lastDeletedEntries ?? this.lastDeletedEntries,
    );
  }

  @override
  List<Object?> get props => [
    status,
    habits,
    histories,
    lastDeleted,
    lastDeletedEntries,
  ];
}
