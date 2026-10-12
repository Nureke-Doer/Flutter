import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/habit.dart';
import '../../l10n/generated/app_localizations.dart';
import '../blocs/categories/categories_cubit.dart';
import '../blocs/habits/habits_bloc.dart';
import '../router/app_router.dart';
import '../widgets/category_grouping.dart';
import '../widgets/empty_state.dart';
import '../widgets/habit_visuals.dart';
import '../widgets/section_header.dart';
import 'habit_detail_screen.dart';

/// Вкладка «Привычки»: все привычки по категориям, архив, управление
/// категориями.
///
/// На планшете (expanded) — схема «список + детали» (master-detail):
/// детали выбранной привычки показываются справа, без перехода.
class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  bool _showArchived = false;
  String? _selectedId;

  Future<void> _create(BuildContext context) async {
    final bloc = context.read<HabitsBloc>();
    final habit = await context.pushNamed<Habit>(AppRoutes.habitNew);
    if (habit != null) bloc.add(HabitSaved(habit));
  }

  void _open(BuildContext context, Habit habit, bool twoPane) {
    if (twoPane) {
      setState(() => _selectedId = habit.id);
    } else {
      context.pushNamed(AppRoutes.habit, pathParameters: {'id': habit.id});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final twoPane = context.windowSize == WindowSize.expanded;
    final allHabits = context.select((HabitsBloc b) => b.state.habits);
    final categories = context.watch<CategoriesCubit>().state;
    final active = allHabits.where((h) => !h.archived).toList();
    final archived = allHabits.where((h) => h.archived).toList();

    final list = active.isEmpty && archived.isEmpty
        ? EmptyState(
            icon: Icons.checklist,
            title: l10n.habitsEmpty,
            message: l10n.todayEmptyHint,
          )
        : ListView(
            padding: const EdgeInsets.fromLTRB(Gaps.m, 0, Gaps.m, 96),
            children: [
              for (final group in groupByCategory(active, categories)) ...[
                SectionHeader(
                  group.category?.name ?? l10n.noCategory,
                  icon: Icons.label_outline,
                  color: group.category == null
                      ? null
                      : Color(group.category!.colorValue),
                ),
                for (final h in group.habits)
                  _HabitRow(
                    habit: h,
                    selected: twoPane && h.id == _selectedId,
                    onTap: () => _open(context, h, twoPane),
                  ),
              ],
              if (archived.isNotEmpty) ...[
                const SizedBox(height: Gaps.m),
                FilterChip(
                  key: const Key('showArchived'),
                  avatar: const Icon(Icons.archive_outlined, size: 18),
                  label: Text(l10n.showArchived(archived.length)),
                  selected: _showArchived,
                  onSelected: (v) => setState(() => _showArchived = v),
                ),
                if (_showArchived)
                  for (final h in archived)
                    _HabitRow(
                      habit: h,
                      selected: twoPane && h.id == _selectedId,
                      onTap: () => _open(context, h, twoPane),
                    ),
              ],
            ],
          );

    final selectedExists = allHabits.any((h) => h.id == _selectedId);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navHabits),
        actions: [
          IconButton(
            key: const Key('categoriesButton'),
            tooltip: l10n.categoriesTitle,
            icon: const Icon(Icons.label_outline),
            onPressed: () => context.pushNamed(AppRoutes.categories),
          ),
        ],
      ),
      // В режиме «список + детали» кнопка слева, чтобы не перекрывать детали.
      floatingActionButtonLocation: twoPane
          ? FloatingActionButtonLocation.startFloat
          : null,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'habitsFab',
        onPressed: () => _create(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.addHabit),
      ),
      body: twoPane
          ? Row(
              children: [
                SizedBox(width: 380, child: list),
                const VerticalDivider(width: 1),
                Expanded(
                  child: selectedExists
                      ? HabitDetailScreen(
                          key: ValueKey(_selectedId),
                          habitId: _selectedId!,
                          embedded: true,
                        )
                      : EmptyState(
                          icon: Icons.touch_app_outlined,
                          title: l10n.selectHabitHint,
                        ),
                ),
              ],
            )
          : list,
    );
  }
}

class _HabitRow extends StatelessWidget {
  const _HabitRow({
    required this.habit,
    required this.onTap,
    this.selected = false,
  });

  final Habit habit;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final streak = context.select(
      (HabitsBloc b) => b.state.historyOf(habit.id).currentStreak,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: Gaps.s),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          selected: selected,
          onTap: onTap,
          leading: CircleAvatar(
            backgroundColor: habit.color.withValues(alpha: 0.15),
            child: Icon(habit.icon.iconData, color: habit.color),
          ),
          title: Text(
            habit.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${habit.kind.label(l10n)} · ${habit.scheduleLabel(context, l10n)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_fire_department,
                size: 18,
                color: streak > 0 ? Colors.deepOrange : null,
              ),
              Text('$streak'),
            ],
          ),
        ),
      ),
    );
  }
}
