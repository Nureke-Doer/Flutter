import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/habit.dart';
import '../blocs/habits/habits_bloc.dart';
import 'entry_value_sheet.dart';

/// Быстрая отметка по нажатию на кружок.
///
/// Обычная привычка и отказ от вредного: пусто ↔ ✔.
/// Числовая привычка: открывается ввод числа.
Future<void> quickMark(BuildContext context, Habit habit, DateTime day) async {
  if (habit.isNumeric) return editEntry(context, habit, day);
  context.read<HabitsBloc>().add(HabitQuickToggled(habit.id, day));
}

/// Полный выбор значения за день: ✔ / ✘ / 0 / число / очистить.
Future<void> editEntry(BuildContext context, Habit habit, DateTime day) async {
  final bloc = context.read<HabitsBloc>();
  final selection = await showEntryValueSheet(
    context,
    habit: habit,
    day: day,
    current: bloc.state.historyOf(habit.id).valueOn(day),
  );
  if (selection != null) {
    bloc.add(HabitEntrySet(habit.id, day, selection.value));
  }
}
