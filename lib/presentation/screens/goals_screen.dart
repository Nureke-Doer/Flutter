import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../domain/services/goal_progress.dart';
import '../../l10n/generated/app_localizations.dart';
import '../blocs/goals/goals_cubit.dart';
import '../blocs/habits/habits_bloc.dart';
import '../router/app_router.dart';
import '../widgets/empty_state.dart';
import '../widgets/goal_card.dart';

/// Вкладка «Цели»: учебные цели с дедлайном и прогрессом.
class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final goals = context.watch<GoalsCubit>().state;
    final habitsState = context.watch<HabitsBloc>().state;
    final today = dateOnly(DateTime.now());
    final progress = [
      for (final g in goals.where((g) => !g.archived))
        GoalProgress.calculate(
          goal: g,
          habits: habitsState.habits,
          histories: habitsState.histories,
          today: today,
        ),
    ];
    // На широком экране карточки идут в две-три колонки.
    final columns = switch (context.windowSize) {
      WindowSize.compact => 1,
      WindowSize.medium => 2,
      WindowSize.expanded => 3,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.goalsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('addGoal'),
        heroTag: 'goalsFab',
        onPressed: () => context.pushNamed(AppRoutes.goalNew),
        icon: const Icon(Icons.add),
        label: Text(l10n.goalAdd),
      ),
      body: progress.isEmpty
          ? EmptyState(
              icon: Icons.flag_outlined,
              title: l10n.goalsEmpty,
              message: l10n.goalsEmptyHint,
            )
          : columns == 1
          ? ListView.builder(
              padding: const EdgeInsets.fromLTRB(Gaps.m, Gaps.s, Gaps.m, 96),
              itemCount: progress.length,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.only(bottom: Gaps.s),
                child: _card(context, progress[i]),
              ),
            )
          // Целей обычно немного, поэтому на широком экране — Wrap:
          // карточки разной высоты не обрезаются.
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(Gaps.m, Gaps.s, Gaps.m, 96),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width =
                      (constraints.maxWidth - Gaps.s * (columns - 1)) / columns;
                  return Wrap(
                    spacing: Gaps.s,
                    runSpacing: Gaps.s,
                    children: [
                      for (final p in progress)
                        SizedBox(width: width, child: _card(context, p)),
                    ],
                  );
                },
              ),
            ),
    );
  }

  Widget _card(BuildContext context, GoalProgress p) => GoalCard(
    progress: p,
    onTap: () => context.pushNamed(
      AppRoutes.goal,
      pathParameters: {'goalId': p.goal.id},
    ),
  );
}
