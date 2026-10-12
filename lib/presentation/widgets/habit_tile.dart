import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../domain/entities/habit.dart';
import '../../core/theme/app_theme.dart';
import 'habit_visuals.dart';

/// Карточка цели в списке «Сегодня».
class HabitTile extends StatelessWidget {
  const HabitTile({
    super.key,
    required this.habit,
    required this.today,
    this.onTap,
    this.onToggle,
  });

  final Habit habit;
  final DateTime today;
  final VoidCallback? onTap;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final done = habit.isCompletedOn(today);
    final streak = habit.currentStreak(today);
    final color = habit.color;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
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
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          size: 16,
                          color: streak > 0
                              ? Colors.deepOrange
                              : theme.colorScheme.outline,
                        ),
                        const SizedBox(width: Gaps.xs),
                        Text(
                          l10n.streakDays(streak),
                          style: theme.textTheme.bodySmall,
                        ),
                        if (habit.targetMinutes != null) ...[
                          const SizedBox(width: Gaps.m),
                          Icon(
                            Icons.timer_outlined,
                            size: 16,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(width: Gaps.xs),
                          Text(
                            l10n.minutesShort(habit.targetMinutes!),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              _CheckButton(done: done, color: color, onPressed: onToggle),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckButton extends StatelessWidget {
  const _CheckButton({required this.done, required this.color, this.onPressed});

  final bool done;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      checked: done,
      child: GestureDetector(
        onTap: onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? color : Colors.transparent,
            border: Border.all(color: color, width: 2),
          ),
          child: done ? const Icon(Icons.check, color: Colors.white) : null,
        ),
      ),
    );
  }
}
