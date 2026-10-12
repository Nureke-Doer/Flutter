import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../domain/entities/habit.dart';
import '../../l10n/generated/app_localizations.dart';
import '../blocs/categories/categories_cubit.dart';
import '../blocs/habits/habits_bloc.dart';
import '../router/app_router.dart';
import '../widgets/category_grouping.dart';
import '../widgets/day_progress_header.dart';
import '../widgets/empty_state.dart';
import '../widgets/entry_actions.dart';
import '../widgets/habit_tile.dart';
import '../widgets/quote_card.dart';
import '../widgets/section_header.dart';

/// Экран «Сегодня»: привычки, запланированные на текущий день,
/// сгруппированные по категориям.
class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  Future<void> _openEditor(BuildContext context) async {
    final bloc = context.read<HabitsBloc>();
    final created = await context.pushNamed<Habit>(AppRoutes.habitNew);
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
        heroTag: 'todayFab',
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
              return _TodayList(state: state, today: today);
          }
        },
      ),
    );
  }
}

class _TodayList extends StatelessWidget {
  const _TodayList({required this.state, required this.today});

  final HabitsState state;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categories = context.watch<CategoriesCubit>().state;
    final planned = state.activeHabits
        .where((h) => h.isScheduledOn(today))
        .toList();
    if (planned.isEmpty) {
      return EmptyState(
        icon: Icons.event_available_outlined,
        title: l10n.todayEmpty,
        message: l10n.todayEmptyHint,
      );
    }

    final done = planned
        .where((h) => state.historyOf(h.id).isSuccessOn(today))
        .length;

    final header = [
      DayProgressHeader(done: done, total: planned.length),
      const QuoteCard(),
    ];
    final items = [
      for (final group in groupByCategory(planned, categories)) ...[
        SectionHeader(
          group.category?.name ?? l10n.noCategory,
          icon: Icons.label_outline,
          color: group.category == null
              ? null
              : Color(group.category!.colorValue),
        ),
        ...group.habits.map((h) => _tile(context, h)),
      ],
    ];

    // Телефон в портрете — одна колонка. Альбомная ориентация и планшет —
    // прогресс дня слева, список справа: так больше привычек на экране.
    if (context.windowSize == WindowSize.compact) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(Gaps.m, Gaps.s, Gaps.m, 96),
        children: [...header, ...items],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 340,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(Gaps.m, Gaps.s, 0, Gaps.m),
            children: header,
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(Gaps.m, 0, Gaps.m, 96),
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _tile(BuildContext context, Habit habit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Gaps.s),
      child: HabitTile(
        habit: habit,
        history: state.historyOf(habit.id),
        today: today,
        onToggle: () => quickMark(context, habit, today),
        onLongPress: () => editEntry(context, habit, today),
        onTap: () => context.pushNamed(
          AppRoutes.habit,
          pathParameters: {'id': habit.id},
        ),
      ),
    );
  }
}
