part of 'habits_bloc.dart';

/// События — всё, что может «случиться» со списком целей.
sealed class HabitsEvent extends Equatable {
  const HabitsEvent();

  @override
  List<Object?> get props => [];
}

/// Подписаться на поток целей из репозитория (отправляется при старте).
final class HabitsSubscriptionRequested extends HabitsEvent {
  const HabitsSubscriptionRequested();
}

/// Отметить / снять отметку выполнения цели за день.
final class HabitToggled extends HabitsEvent {
  const HabitToggled(this.habitId, this.day);

  final String habitId;
  final DateTime day;

  @override
  List<Object?> get props => [habitId, day];
}

/// Создать новую или сохранить изменённую цель.
final class HabitSaved extends HabitsEvent {
  const HabitSaved(this.habit);

  final Habit habit;

  @override
  List<Object?> get props => [habit];
}

/// Удалить цель.
final class HabitDeleted extends HabitsEvent {
  const HabitDeleted(this.habitId);

  final String habitId;

  @override
  List<Object?> get props => [habitId];
}

/// Отменить последнее удаление (кнопка «Отменить» в SnackBar).
final class HabitDeletionUndone extends HabitsEvent {
  const HabitDeletionUndone();
}
