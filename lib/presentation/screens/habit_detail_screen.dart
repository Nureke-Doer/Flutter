import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_history.dart';
import '../../l10n/generated/app_localizations.dart';
import '../blocs/categories/categories_cubit.dart';
import '../blocs/habits/habits_bloc.dart';
import '../widgets/entry_actions.dart';
import '../widgets/habit_visuals.dart';
import '../widgets/month_calendar.dart';
import '../widgets/monthly_table.dart';
import '../widgets/stat_card.dart';
import 'habit_edit_screen.dart';
import 'materials_screen.dart';

/// Детальная информация о привычке: серии, статистика, календарь,
/// тепловая карта и таблица по месяцам.
///
/// Экран получает только `habitId` и через `context.select` подписывается
/// именно на эту привычку и её историю в состоянии [HabitsBloc]:
/// изменения других привычек его не перестраивают.
class HabitDetailScreen extends StatelessWidget {
  const HabitDetailScreen({super.key, required this.habitId});

  final String habitId;

  Future<void> _edit(BuildContext context, Habit habit) async {
    final bloc = context.read<HabitsBloc>();
    final updated = await Navigator.of(context).push<Habit>(
      MaterialPageRoute(builder: (_) => HabitEditScreen(initial: habit)),
    );
    if (updated != null) bloc.add(HabitSaved(updated));
  }

  Future<void> _delete(BuildContext context, Habit habit) async {
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<HabitsBloc>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle(habit.title)),
        content: Text(l10n.deleteConfirmBody),
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
    if (confirmed == true) {
      navigator.pop();
      bloc.add(HabitDeleted(habit.id));
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.deletedMessage),
          action: SnackBarAction(
            label: l10n.undo,
            onPressed: () => bloc.add(const HabitDeletionUndone()),
          ),
        ),
      );
    }
  }

  void _toggleArchive(BuildContext context, Habit habit) {
    final l10n = AppLocalizations.of(context);
    context.read<HabitsBloc>().add(HabitArchiveToggled(habit.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(habit.archived ? l10n.unarchived : l10n.archived)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final habit = context.select((HabitsBloc bloc) => bloc.state.byId(habitId));
    final history = context.select(
      (HabitsBloc bloc) => bloc.state.historyOf(habitId),
    );
    // Привычка могла быть удалена, пока экран закрывается.
    if (habit == null) return const Scaffold();
    final l10n = AppLocalizations.of(context);
    final today = dateOnly(DateTime.now());
    final todayValue = history.valueOn(today);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: l10n.edit,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _edit(context, habit),
          ),
          IconButton(
            tooltip: habit.archived ? l10n.unarchive : l10n.archive,
            icon: Icon(
              habit.archived
                  ? Icons.unarchive_outlined
                  : Icons.archive_outlined,
            ),
            onPressed: () => _toggleArchive(context, habit),
          ),
          IconButton(
            tooltip: l10n.delete,
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _delete(context, habit),
          ),
        ],
      ),
      bottomNavigationBar: habit.archived
          ? null
          : SafeArea(
              minimum: const EdgeInsets.all(Gaps.m),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      key: const Key('toggleTodayButton'),
                      onPressed: () => quickMark(context, habit, today),
                      icon: Icon(
                        (todayValue?.isSuccess ?? false)
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                      ),
                      label: Text(
                        todayValue == null
                            ? l10n.detailMarkToday
                            : '${l10n.todayTitle}: '
                                  '${habit.valueLabel(todayValue, l10n)}',
                      ),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                    ),
                  ),
                  const SizedBox(width: Gaps.s),
                  IconButton.filledTonal(
                    key: const Key('moreValuesButton'),
                    tooltip: l10n.entryMoreValues,
                    onPressed: () => editEntry(context, habit, today),
                    icon: const Icon(Icons.more_horiz),
                  ),
                ],
              ),
            ),
      body: ListView(
        padding: const EdgeInsets.all(Gaps.m),
        children: [
          _Header(habit: habit),
          const SizedBox(height: Gaps.m),
          _Stats(habit: habit, history: history, today: today),
          const SizedBox(height: Gaps.m),
          _CardSection(
            title: l10n.detailCalendar,
            child: MonthCalendar(
              habit: habit,
              history: history,
              today: today,
              onDayTap: (day) => editEntry(context, habit, day),
            ),
          ),
          const SizedBox(height: Gaps.m),
          _CardSection(
            title: l10n.detailHeatmap,
            child: CalendarHeatmap(
              habit: habit,
              history: history,
              today: today,
            ),
          ),
          if (history.monthly.isNotEmpty) ...[
            const SizedBox(height: Gaps.m),
            _CardSection(
              title: l10n.detailByMonth,
              child: MonthlyTable(habit: habit, months: history.monthly),
            ),
          ],
          const SizedBox(height: Gaps.m),
          _Info(habit: habit),
          const SizedBox(height: Gaps.m),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => MaterialsScreen(initialQuery: habit.title),
              ),
            ),
            icon: const Icon(Icons.auto_stories_outlined),
            label: Text(l10n.findMaterials),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final category = context.select(
      (CategoriesCubit c) => c.byId(habit.categoryId),
    );
    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: habit.color.withValues(alpha: 0.15),
          child: Icon(habit.icon.iconData, color: habit.color, size: 32),
        ),
        const SizedBox(width: Gaps.m),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(habit.title, style: theme.textTheme.headlineSmall),
              const SizedBox(height: Gaps.xs),
              Wrap(
                spacing: Gaps.s,
                runSpacing: Gaps.xs,
                children: [
                  Chip(
                    avatar: Icon(habit.kind.iconData, size: 18),
                    label: Text(habit.kind.label(l10n)),
                    visualDensity: VisualDensity.compact,
                  ),
                  Chip(
                    avatar: const Icon(Icons.label_outline, size: 18),
                    label: Text(category?.name ?? l10n.noCategory),
                    visualDensity: VisualDensity.compact,
                  ),
                  if (habit.archived)
                    Chip(
                      avatar: const Icon(Icons.archive_outlined, size: 18),
                      label: Text(l10n.archivedBadge),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({
    required this.habit,
    required this.history,
    required this.today,
  });

  final Habit habit;
  final HabitHistory history;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rate = history.completionRate(habit, today, days: 30);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.local_fire_department,
                color: Colors.deepOrange,
                value: '${history.currentStreak}',
                label: l10n.detailCurrentStreak,
              ),
            ),
            const SizedBox(width: Gaps.s),
            Expanded(
              child: StatCard(
                icon: Icons.emoji_events_outlined,
                color: Colors.amber.shade700,
                value: '${history.bestStreak}',
                label: l10n.detailBestStreak,
              ),
            ),
            const SizedBox(width: Gaps.s),
            Expanded(
              child: StatCard(
                icon: Icons.insights,
                color: habit.color,
                value: '${(rate * 100).round()}%',
                label: l10n.detailCompletion,
              ),
            ),
          ],
        ),
        const SizedBox(height: Gaps.s),
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.task_alt,
                color: Colors.green,
                value: '${history.successCount}',
                label: l10n.detailTotalDone,
              ),
            ),
            const SizedBox(width: Gaps.s),
            Expanded(
              child: StatCard(
                icon: Icons.close,
                color: EntryColors.failed,
                value: '${history.failureCount}',
                label: habit.kind == HabitKind.quit
                    ? l10n.detailRelapses
                    : l10n.detailFailures,
              ),
            ),
            if (habit.isNumeric) ...[
              const SizedBox(width: Gaps.s),
              Expanded(
                child: StatCard(
                  icon: Icons.functions,
                  color: Colors.indigo,
                  value: formatAmount(history.totalAmount),
                  label: l10n.detailSum(habit.unit ?? ''),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _CardSection extends StatelessWidget {
  const _CardSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Gaps.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: Gaps.m),
            child,
          ],
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Column(
        children: [
          if (habit.description.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.notes),
              title: Text(l10n.detailDescription),
              subtitle: Text(habit.description),
            ),
          ListTile(
            leading: const Icon(Icons.calendar_month_outlined),
            title: Text(l10n.detailSchedule),
            subtitle: Text(habit.scheduleLabel(context, l10n)),
          ),
          if (habit.isNumeric)
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: Text(l10n.detailTarget),
              subtitle: Text(
                habit.target == null
                    ? l10n.detailNoTarget
                    : formatAmount(habit.target!, habit.unit),
              ),
            ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: Text(l10n.detailReminder),
            subtitle: Text(
              habit.reminderMinutes == null
                  ? l10n.detailNoReminder
                  : formatMinutes(context, habit.reminderMinutes!),
            ),
          ),
        ],
      ),
    );
  }
}
