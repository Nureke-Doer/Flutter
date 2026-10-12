import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/habit.dart';
import '../state/habits_scope.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils.dart';
import '../widgets/habit_visuals.dart';
import '../widgets/month_calendar.dart';
import '../widgets/stat_card.dart';
import 'habit_edit_screen.dart';

/// Детальная информация о цели: серии, процент выполнения, календарь.
///
/// Неделя 3, шаг 2 (InheritedWidget): экран получает только `habitId`
/// и сам находит актуальную цель в `HabitsScope`. После отметки или
/// редактирования экран перестраивается автоматически.
class HabitDetailScreen extends StatelessWidget {
  const HabitDetailScreen({super.key, required this.habitId});

  final String habitId;

  Future<void> _edit(BuildContext context, Habit habit) async {
    final scope = HabitsScope.read(context);
    final updated = await Navigator.of(context).push<Habit>(
      MaterialPageRoute(builder: (_) => HabitEditScreen(initial: habit)),
    );
    if (updated != null) scope.save(updated);
  }

  Future<void> _delete(BuildContext context, Habit habit) async {
    final l10n = AppLocalizations.of(context);
    final scope = HabitsScope.read(context);
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
      scope.delete(habit.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scope = HabitsScope.of(context);
    final habit = scope.byId(habitId);
    // Цель могла быть удалена, пока экран закрывается.
    if (habit == null) return const Scaffold();
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final today = dateOnly(DateTime.now());
    final rate = habit.completionRate(today, days: 30);
    final doneToday = habit.isCompletedOn(today);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: l10n.edit,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _edit(context, habit),
          ),
          IconButton(
            tooltip: l10n.delete,
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _delete(context, habit),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(Gaps.m),
        child: doneToday
            ? FilledButton.tonalIcon(
                key: const Key('toggleTodayButton'),
                onPressed: () => scope.toggle(habit.id, today),
                icon: const Icon(Icons.check_circle),
                label: Text(l10n.detailDoneToday),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              )
            : FilledButton.icon(
                key: const Key('toggleTodayButton'),
                onPressed: habit.isScheduledOn(today)
                    ? () => scope.toggle(habit.id, today)
                    : null,
                icon: const Icon(Icons.radio_button_unchecked),
                label: Text(l10n.detailMarkToday),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Gaps.m),
        children: [
          Row(
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
                    Chip(
                      avatar: Icon(habit.type.iconData, size: 18),
                      label: Text(habit.type.label(l10n)),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Gaps.m),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.local_fire_department,
                  color: Colors.deepOrange,
                  value: '${habit.currentStreak(today)}',
                  label: l10n.detailCurrentStreak,
                ),
              ),
              const SizedBox(width: Gaps.s),
              Expanded(
                child: StatCard(
                  icon: Icons.emoji_events_outlined,
                  color: Colors.amber.shade700,
                  value: '${habit.bestStreak(today)}',
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
          const SizedBox(height: Gaps.m),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(Gaps.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.detailCalendar, style: theme.textTheme.titleMedium),
                  const SizedBox(height: Gaps.m),
                  MonthCalendar(habit: habit, month: today),
                ],
              ),
            ),
          ),
          const SizedBox(height: Gaps.m),
          Card(
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
                  subtitle: Text(
                    habit.isEveryDay
                        ? l10n.detailEveryDay
                        : (habit.weekdays.toList()..sort())
                              .map((d) => weekdayShort(context, d))
                              .join(', '),
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
                if (habit.targetMinutes != null)
                  ListTile(
                    leading: const Icon(Icons.timer_outlined),
                    title: Text(l10n.detailTarget),
                    subtitle: Text(l10n.minutesShort(habit.targetMinutes!)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
