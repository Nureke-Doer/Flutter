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
class HabitDetailScreen extends StatelessWidget {
  const HabitDetailScreen({super.key, required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final today = dateOnly(DateTime.now());
    final rate = habit.completionRate(today, days: 30);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: l10n.edit,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => HabitEditScreen(initial: habit),
              ),
            ),
          ),
        ],
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
