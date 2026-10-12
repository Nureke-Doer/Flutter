import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils.dart';
import '../widgets/habit_visuals.dart';
import '../widgets/month_calendar.dart';
import '../widgets/stat_card.dart';
import 'habit_edit_screen.dart';

/// Детальная информация о цели: серии, процент выполнения, календарь.
///
/// Неделя 3, шаг 1 (setState): экран получает копию цели и колбэки.
/// Чтобы экран обновлялся после изменений, приходится хранить
/// локальную копию `_habit` и синхронизировать её вручную.
class HabitDetailScreen extends StatefulWidget {
  const HabitDetailScreen({
    super.key,
    required this.habit,
    required this.onToggle,
    required this.onSave,
    required this.onDelete,
  });

  final Habit habit;
  final void Function(Habit habit, DateTime day) onToggle;
  final ValueChanged<Habit> onSave;
  final ValueChanged<Habit> onDelete;

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  late Habit _habit = widget.habit;

  void _toggleToday() {
    final today = dateOnly(DateTime.now());
    widget.onToggle(_habit, today);
    setState(() => _habit = _habit.toggleDay(today));
  }

  Future<void> _edit() async {
    final updated = await Navigator.of(context).push<Habit>(
      MaterialPageRoute(builder: (_) => HabitEditScreen(initial: _habit)),
    );
    if (updated != null) {
      widget.onSave(updated);
      setState(() => _habit = updated);
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle(_habit.title)),
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
    if (confirmed == true && mounted) {
      widget.onDelete(_habit);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final habit = _habit;
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
            onPressed: _edit,
          ),
          IconButton(
            tooltip: l10n.delete,
            icon: const Icon(Icons.delete_outline),
            onPressed: _delete,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(Gaps.m),
        child: doneToday
            ? FilledButton.tonalIcon(
                key: const Key('toggleTodayButton'),
                onPressed: _toggleToday,
                icon: const Icon(Icons.check_circle),
                label: Text(l10n.detailDoneToday),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              )
            : FilledButton.icon(
                key: const Key('toggleTodayButton'),
                onPressed: habit.isScheduledOn(today) ? _toggleToday : null,
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
