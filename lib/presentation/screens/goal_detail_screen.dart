import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../domain/entities/book.dart';
import '../../domain/services/goal_progress.dart';
import '../../l10n/generated/app_localizations.dart';
import '../blocs/goals/goals_cubit.dart';
import '../blocs/habits/habits_bloc.dart';
import '../router/app_router.dart';
import '../widgets/book_cover.dart';
import '../widgets/goal_card.dart';
import '../widgets/habit_visuals.dart';
import '../widgets/number_dialog.dart';
import '../widgets/stat_card.dart';

/// Учебная цель: прогресс, сколько нужно в день, вклад привязанных привычек.
class GoalDetailScreen extends StatelessWidget {
  const GoalDetailScreen({super.key, required this.goalId});

  final String goalId;

  Future<void> _addProgress(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<GoalsCubit>();
    final goal = cubit.byId(goalId);
    if (goal == null) return;
    final value = await showNumberDialog(
      context,
      title: l10n.goalAddProgress,
      unit: goal.unit,
      allowNegative: true,
    );
    if (value == null) return;
    await cubit.save(
      goal.copyWith(manualProgress: goal.manualProgress + value),
    );
  }

  Future<void> _delete(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<GoalsCubit>();
    final goal = cubit.byId(goalId);
    if (goal == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle(goal.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.pop();
      await cubit.delete(goalId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final goal = context.select((GoalsCubit c) => c.byId(goalId));
    if (goal == null) return const Scaffold();
    final habitsState = context.watch<HabitsBloc>().state;
    final today = dateOnly(DateTime.now());
    final progress = GoalProgress.calculate(
      goal: goal,
      habits: habitsState.habits,
      histories: habitsState.histories,
      today: today,
    );
    final linked = habitsState.habits
        .where((h) => goal.linkedHabitIds.contains(h.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(goal.title),
        actions: [
          IconButton(
            tooltip: l10n.edit,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.pushNamed(
              AppRoutes.goalEdit,
              pathParameters: {'goalId': goalId},
            ),
          ),
          IconButton(
            tooltip: l10n.delete,
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _delete(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(Gaps.m),
        children: [
          Center(
            child: SizedBox.square(
              dimension: 160,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: progress.fraction,
                    strokeWidth: 12,
                    strokeCap: StrokeCap.round,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(progress.fraction * 100).round()}%',
                          style: theme.textTheme.headlineMedium,
                        ),
                        Text(
                          '${formatAmount(progress.current)} / '
                          '${formatAmount(goal.target, goal.unit)}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Gaps.m),
          Text(
            goalStatusText(progress, l10n),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall,
          ),
          if (goal.description.isNotEmpty) ...[
            const SizedBox(height: Gaps.s),
            Text(goal.description, textAlign: TextAlign.center),
          ],
          const SizedBox(height: Gaps.m),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.hourglass_bottom,
                  value: formatAmount(progress.remaining),
                  label: l10n.goalRemaining(goal.unit),
                ),
              ),
              const SizedBox(width: Gaps.s),
              Expanded(
                child: StatCard(
                  icon: Icons.event,
                  color: Colors.indigo,
                  value: '${progress.daysLeft < 0 ? 0 : progress.daysLeft}',
                  label: l10n.goalDaysLeftLabel,
                ),
              ),
            ],
          ),
          if (goal.bookTitle != null) ...[
            const SizedBox(height: Gaps.m),
            Card(
              child: ListTile(
                leading: BookCover(
                  book: Book(
                    id: goal.id,
                    title: goal.bookTitle!,
                    coverId: goal.bookCoverId,
                  ),
                  width: 40,
                ),
                title: Text(goal.bookTitle!),
                subtitle: Text(l10n.goalBook),
              ),
            ),
          ],
          const SizedBox(height: Gaps.m),
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(Gaps.m, Gaps.m, Gaps.m, 0),
                  child: Text(
                    l10n.goalLinkedHabits,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                if (linked.isEmpty)
                  ListTile(title: Text(l10n.goalNoLinkedHabits)),
                for (final h in linked)
                  ListTile(
                    leading: Icon(h.icon.iconData, color: h.color),
                    title: Text(h.title),
                    trailing: Text(
                      '+${formatAmount(GoalProgress.contribution(goal, h, habitsState.historyOf(h.id)))}',
                    ),
                    onTap: () => context.pushNamed(
                      AppRoutes.habit,
                      pathParameters: {'id': h.id},
                    ),
                  ),
                if (goal.manualProgress != 0)
                  ListTile(
                    leading: const Icon(Icons.edit_note),
                    title: Text(l10n.goalManualProgress),
                    trailing: Text(formatAmount(goal.manualProgress)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: Gaps.m),
          FilledButton.tonalIcon(
            key: const Key('addProgressButton'),
            onPressed: () => _addProgress(context),
            icon: const Icon(Icons.add),
            label: Text(l10n.goalAddProgress),
          ),
          const SizedBox(height: Gaps.s),
          OutlinedButton.icon(
            onPressed: () => context.pushNamed(
              AppRoutes.materials,
              queryParameters: {'q': goal.bookTitle ?? goal.title},
            ),
            icon: const Icon(Icons.auto_stories_outlined),
            label: Text(l10n.findMaterials),
          ),
        ],
      ),
    );
  }
}
