import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../domain/entities/habit.dart';
import '../../l10n/generated/app_localizations.dart';
import '../blocs/habits/habits_bloc.dart';
import '../widgets/day_progress_header.dart';
import '../widgets/empty_state.dart';
import '../widgets/habit_tile.dart';
import '../widgets/habit_visuals.dart';
import '../widgets/section_header.dart';
import 'habit_detail_screen.dart';
import 'habit_edit_screen.dart';

/// Экран «Сегодня»: цели, запланированные на текущий день.
class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  Future<void> _openEditor(BuildContext context) async {
    final bloc = context.read<HabitsBloc>();
    final created = await Navigator.of(
      context,
    ).push<Habit>(MaterialPageRoute(builder: (_) => const HabitEditScreen()));
    if (created != null) bloc.add(HabitSaved(created));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final today = dateOnly(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.todayTitle),
            Text(
              DateFormat.MMMMEEEEd(locale).format(today),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.addHabit),
      ),
      // BlocBuilder перестраивает тело экрана при каждом новом состоянии.
      body: BlocBuilder<HabitsBloc, HabitsState>(
        builder: (context, state) {
          switch (state.status) {
            case HabitsStatus.initial:
            case HabitsStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case HabitsStatus.failure:
              return EmptyState(
                icon: Icons.error_outline,
                title: l10n.errorLoading,
                action: FilledButton(
                  onPressed: () => context.read<HabitsBloc>().add(
                    const HabitsSubscriptionRequested(),
                  ),
                  child: Text(l10n.retry),
                ),
              );
            case HabitsStatus.success:
              return _TodayList(habits: state.habits, today: today);
          }
        },
      ),
    );
  }
}

class _TodayList extends StatelessWidget {
  const _TodayList({required this.habits, required this.today});

  final List<Habit> habits;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final planned = habits.where((h) => h.isScheduledOn(today)).toList();
    if (planned.isEmpty) {
      return EmptyState(
        icon: Icons.event_available_outlined,
        title: l10n.todayEmpty,
        message: l10n.todayEmptyHint,
      );
    }

    final habitItems = planned.where((h) => h.type == HabitType.habit).toList();
    final studyItems = planned.where((h) => h.type == HabitType.study).toList();
    final done = planned.where((h) => h.isCompletedOn(today)).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(Gaps.m, Gaps.s, Gaps.m, 96),
      children: [
        DayProgressHeader(done: done, total: planned.length),
        if (habitItems.isNotEmpty) ...[
          SectionHeader(l10n.sectionHabits, icon: HabitType.habit.iconData),
          ...habitItems.map((h) => _tile(context, h)),
        ],
        if (studyItems.isNotEmpty) ...[
          SectionHeader(l10n.sectionStudy, icon: HabitType.study.iconData),
          ...studyItems.map((h) => _tile(context, h)),
        ],
      ],
    );
  }

  Widget _tile(BuildContext context, Habit habit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Gaps.s),
      child: HabitTile(
        habit: habit,
        today: today,
        onToggle: () =>
            context.read<HabitsBloc>().add(HabitToggled(habit.id, today)),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => HabitDetailScreen(habitId: habit.id),
          ),
        ),
      ),
    );
  }
}
