import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/goals/goals_cubit.dart';
import '../blocs/habits/habits_bloc.dart';
import '../blocs/metrics/metrics_cubit.dart';
import 'goal_edit_screen.dart';
import 'habit_edit_screen.dart';
import 'metric_edit_screen.dart';

/// Обёртки для маршрутов редактирования по id (`/habit/:id/edit` и т.п.).
///
/// По прямой ссылке (или после обновления страницы в браузере) экран может
/// открыться раньше, чем данные загрузились из Hive. Без ожидания форма
/// открылась бы пустой, и сохранение создало бы новую запись вместо
/// изменения существующей. Поэтому пока данных нет — индикатор загрузки.

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

class HabitEditLoader extends StatelessWidget {
  const HabitEditLoader({super.key, required this.habitId});

  final String habitId;

  @override
  Widget build(BuildContext context) {
    final loaded = context.select(
      (HabitsBloc b) => b.state.status == HabitsStatus.success,
    );
    if (!loaded) return const _Loading();
    // Данные загружены: берём привычку один раз (форма дальше живёт сама).
    final habit = context.read<HabitsBloc>().state.byId(habitId);
    if (habit == null) return const Scaffold(body: SizedBox.shrink());
    return HabitEditScreen(initial: habit);
  }
}

class GoalEditLoader extends StatelessWidget {
  const GoalEditLoader({super.key, required this.goalId});

  final String goalId;

  @override
  Widget build(BuildContext context) {
    final found = context.select((GoalsCubit c) => c.byId(goalId) != null);
    if (!found) return const _Loading();
    return GoalEditScreen(initial: context.read<GoalsCubit>().byId(goalId));
  }
}

class MetricEditLoader extends StatelessWidget {
  const MetricEditLoader({super.key, required this.metricId});

  final String metricId;

  @override
  Widget build(BuildContext context) {
    final found = context.select(
      (MetricsCubit c) => c.state.byId(metricId) != null,
    );
    if (!found) return const _Loading();
    return MetricEditScreen(
      initial: context.read<MetricsCubit>().state.byId(metricId),
    );
  }
}
