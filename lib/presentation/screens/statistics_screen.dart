import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../domain/services/habit_statistics.dart';
import '../blocs/habits/habits_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils.dart';
import '../widgets/empty_state.dart';
import '../widgets/habit_visuals.dart';
import '../widgets/stat_card.dart';
import '../widgets/weekly_bar_chart.dart';

/// Экран статистики: общий процент, график за неделю, лидеры по сериям.
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final today = dateOnly(DateTime.now());
    final habits = context.select((HabitsBloc bloc) => bloc.state.habits);

    if (habits.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.statsTitle)),
        body: EmptyState(icon: Icons.insights, title: l10n.statsEmpty),
      );
    }

    // Вся математика — в доменном слое (HabitStatistics), экран только рисует.
    final stats = HabitStatistics.from(habits, today);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.statsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(Gaps.m),
        children: [
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.percent,
                  value: '${(stats.weekRate * 100).round()}%',
                  label: l10n.statsWeekRate,
                ),
              ),
              const SizedBox(width: Gaps.s),
              Expanded(
                child: StatCard(
                  icon: Icons.task_alt,
                  color: Colors.green,
                  value: '${stats.totalCheckIns}',
                  label: l10n.statsCompletedTotal,
                ),
              ),
              const SizedBox(width: Gaps.s),
              Expanded(
                child: StatCard(
                  icon: Icons.flag_outlined,
                  color: Colors.indigo,
                  value: '${stats.activeCount}',
                  label: l10n.statsActiveHabits,
                ),
              ),
            ],
          ),
          const SizedBox(height: Gaps.m),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(Gaps.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.statsLast7Days, style: theme.textTheme.titleMedium),
                  const SizedBox(height: Gaps.m),
                  WeeklyBarChart(days: stats.days, values: stats.dailyRates),
                ],
              ),
            ),
          ),
          const SizedBox(height: Gaps.m),
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(Gaps.m, Gaps.m, Gaps.m, 0),
                  child: Text(
                    l10n.statsTopStreaks,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                for (final habit in stats.topByStreak)
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: habit.color.withValues(alpha: 0.15),
                      child: Icon(habit.icon.iconData, color: habit.color),
                    ),
                    title: Text(
                      habit.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: LinearProgressIndicator(
                      value: habit.completionRate(today),
                      color: habit.color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          color: Colors.deepOrange,
                          size: 20,
                        ),
                        Text(
                          '${habit.currentStreak(today)}',
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: Gaps.s),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
