part of 'habits_bloc.dart';

enum HabitsStatus { initial, loading, success, failure }

/// Состояние списка целей. Неизменяемое: новое состояние создаётся через
/// [copyWith], а `Equatable` позволяет BLoC не перерисовывать UI,
/// если состояние не изменилось.
final class HabitsState extends Equatable {
  const HabitsState({
    this.status = HabitsStatus.initial,
    this.habits = const [],
    this.lastDeleted,
  });

  final HabitsStatus status;
  final List<Habit> habits;

  /// Последняя удалённая цель — для отмены удаления.
  final Habit? lastDeleted;

  Habit? byId(String id) {
    for (final h in habits) {
      if (h.id == id) return h;
    }
    return null;
  }

  HabitsState copyWith({
    HabitsStatus? status,
    List<Habit>? habits,
    Habit? Function()? lastDeleted,
  }) {
    return HabitsState(
      status: status ?? this.status,
      habits: habits ?? this.habits,
      lastDeleted: lastDeleted != null ? lastDeleted() : this.lastDeleted,
    );
  }

  @override
  List<Object?> get props => [status, habits, lastDeleted];
}
