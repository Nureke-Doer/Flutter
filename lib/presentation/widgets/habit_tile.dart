import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_entry.dart';
import '../../domain/entities/habit_history.dart';
import '../../l10n/generated/app_localizations.dart';
import 'habit_visuals.dart';

/// Карточка привычки в списке «Сегодня».
///
/// Нажатие на кружок — быстрая отметка (для числовой привычки —
/// ввод числа), долгое нажатие — выбор ✔ / ✘ / 0 / число.
class HabitTile extends StatelessWidget {
  const HabitTile({
    super.key,
    required this.habit,
    required this.history,
    required this.today,
    this.onTap,
    this.onToggle,
    this.onLongPress,
  });

  final Habit habit;
  final HabitHistory history;
  final DateTime today;
  final VoidCallback? onTap;
  final VoidCallback? onToggle;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final value = history.valueOn(today);
    final done = value?.isSuccess ?? false;
    final streak = history.currentStreak;
    final color = habit.color;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Gaps.m, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(habit.icon.iconData, color: color),
              ),
              const SizedBox(width: Gaps.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        decoration: done ? TextDecoration.lineThrough : null,
                        color: done ? theme.colorScheme.onSurfaceVariant : null,
                      ),
                    ),
                    const SizedBox(height: Gaps.xs),
                    Wrap(
                      spacing: Gaps.m,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _Info(
                          icon: Icons.local_fire_department,
                          color: streak > 0 ? Colors.deepOrange : null,
                          text: l10n.streakDays(streak),
                        ),
                        if (habit.isNumeric)
                          _Info(
                            icon: Icons.straighten,
                            text: habit.target == null
                                ? formatAmount(value?.amount ?? 0, habit.unit)
                                : '${formatAmount(value?.amount ?? 0)} / '
                                      '${formatAmount(habit.target!, habit.unit)}',
                          ),
                        if (habit.schedule.type == ScheduleType.timesPerWeek)
                          _Info(
                            icon: Icons.date_range,
                            text: l10n.weekProgress(
                              history.successesInWeek(today),
                              habit.schedule.timesPerWeek,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              EntryButton(
                value: value,
                color: color,
                onPressed: onToggle,
                onLongPress: onLongPress,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.icon, required this.text, this.color});

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color ?? theme.colorScheme.outline),
        const SizedBox(width: Gaps.xs),
        Text(text, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

/// Круглая кнопка отметки: показывает ✔ / ✘ / 0 / число.
class EntryButton extends StatelessWidget {
  const EntryButton({
    super.key,
    required this.value,
    required this.color,
    this.onPressed,
    this.onLongPress,
    this.size = 40,
  });

  final EntryValue? value;
  final Color color;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final double size;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outline;
    final (Color fill, Color border, Widget? child) = switch (value) {
      null => (Colors.transparent, color, null),
      EntryDone() => (
        color,
        color,
        const Icon(Icons.check, color: Colors.white),
      ),
      EntryFailed() => (
        EntryColors.failed,
        EntryColors.failed,
        const Icon(Icons.close, color: Colors.white),
      ),
      EntrySkipped() => (
        Colors.transparent,
        outline,
        Text('0', style: TextStyle(color: outline)),
      ),
      EntryAmount(:final amount) => (
        amount > 0 ? color : Colors.transparent,
        amount > 0 ? color : outline,
        FittedBox(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Text(
              formatAmount(amount),
              style: TextStyle(
                color: amount > 0 ? Colors.white : outline,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    };

    return Semantics(
      button: true,
      checked: value?.isSuccess ?? false,
      child: GestureDetector(
        onTap: onPressed,
        onLongPress: onLongPress,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: fill,
            border: Border.all(color: border, width: 2),
          ),
          child: child,
        ),
      ),
    );
  }
}
