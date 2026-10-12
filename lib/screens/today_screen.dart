import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils.dart';
import '../widgets/day_progress_header.dart';
import '../widgets/empty_state.dart';
import '../widgets/habit_tile.dart';
import '../widgets/habit_visuals.dart';
import '../widgets/section_header.dart';
import 'habit_detail_screen.dart';
import 'habit_edit_screen.dart';

/// Экран «Сегодня»: цели, запланированные на текущий день.
class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key, required this.habits});

  final List<Habit> habits;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final today = dateOnly(DateTime.now());
    final planned = habits.where((h) => h.isScheduledOn(today)).toList();
    final habitItems = planned.where((h) => h.type == HabitType.habit).toList();
    final studyItems = planned.where((h) => h.type == HabitType.study).toList();
    final done = planned.where((h) => h.isCompletedOn(today)).length;
    final dateLabel = DateFormat.MMMMEEEEd(locale).format(today);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.todayTitle),
            Text(dateLabel, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const HabitEditScreen()),
        ),
        icon: const Icon(Icons.add),
        label: Text(l10n.addHabit),
      ),
      body: planned.isEmpty
          ? EmptyState(
              icon: Icons.event_available_outlined,
              title: l10n.todayEmpty,
              message: l10n.todayEmptyHint,
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(Gaps.m, Gaps.s, Gaps.m, 96),
              children: [
                DayProgressHeader(done: done, total: planned.length),
                if (habitItems.isNotEmpty) ...[
                  SectionHeader(
                    l10n.sectionHabits,
                    icon: HabitType.habit.iconData,
                  ),
                  ..._tiles(context, habitItems, today),
                ],
                if (studyItems.isNotEmpty) ...[
                  SectionHeader(
                    l10n.sectionStudy,
                    icon: HabitType.study.iconData,
                  ),
                  ..._tiles(context, studyItems, today),
                ],
              ],
            ),
    );
  }

  Iterable<Widget> _tiles(
    BuildContext context,
    List<Habit> items,
    DateTime today,
  ) {
    return items.map(
      (habit) => Padding(
        padding: const EdgeInsets.only(bottom: Gaps.s),
        child: HabitTile(
          habit: habit,
          today: today,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => HabitDetailScreen(habit: habit),
            ),
          ),
        ),
      ),
    );
  }
}
