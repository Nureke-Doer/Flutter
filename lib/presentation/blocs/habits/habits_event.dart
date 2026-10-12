part of 'habits_bloc.dart';

/// События — всё, что может «случиться» со списком привычек.
sealed class HabitsEvent extends Equatable {
  const HabitsEvent();

  @override
  List<Object?> get props => [];
}

/// Подписаться на привычки и отметки из репозитория (отправляется при старте).
final class HabitsSubscriptionRequested extends HabitsEvent {
  const HabitsSubscriptionRequested();
}

/// Быстрая отметка одним нажатием: пусто → ✔ (или цель для числовой),
/// выполнено → пусто.
final class HabitQuickToggled extends HabitsEvent {
  const HabitQuickToggled(this.habitId, this.day);

  final String habitId;
  final DateTime day;

  @override
  List<Object?> get props => [habitId, day];
}

/// Установить конкретное значение за день: ✔ / ✘ / 0 / число,
/// `null` — очистить («пусто»).
final class HabitEntrySet extends HabitsEvent {
  const HabitEntrySet(this.habitId, this.day, this.value);

  final String habitId;
  final DateTime day;
  final EntryValue? value;

  @override
  List<Object?> get props => [habitId, day, value];
}

/// Создать новую или сохранить изменённую привычку.
final class HabitSaved extends HabitsEvent {
  const HabitSaved(this.habit);

  final Habit habit;

  @override
  List<Object?> get props => [habit];
}

/// Отправить привычку в архив или вернуть из архива.
final class HabitArchiveToggled extends HabitsEvent {
  const HabitArchiveToggled(this.habitId);

  final String habitId;

  @override
  List<Object?> get props => [habitId];
}

/// Удалить привычку вместе с историей.
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
