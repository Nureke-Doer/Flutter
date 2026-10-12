import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/services/goal_progress.dart';
import '../../l10n/generated/app_localizations.dart';
import 'habit_visuals.dart';

/// Строка «осталось N дней / просрочено / выполнено» для учебной цели.
String goalStatusText(GoalProgress p, AppLocalizations l10n) {
  if (p.isCompleted) return l10n.goalCompleted;
  if (p.isOverdue) return l10n.goalOverdue;
  final perDay = p.neededPerDay;
  final left = l10n.goalDaysLeft(p.daysLeft);
  return perDay == null
      ? left
      : '$left · ${l10n.goalPerDay(formatAmount(perDay.ceilToDouble(), p.goal.unit))}';
}

/// Карточка учебной цели с прогрессом.
class GoalCard extends StatelessWidget {
  const GoalCard({super.key, required this.progress, this.onTap});

  final GoalProgress progress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final goal = progress.goal;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final color = progress.isCompleted
        ? Colors.green
        : progress.isOverdue
        ? theme.colorScheme.error
        : theme.colorScheme.primary;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Gaps.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    progress.isCompleted ? Icons.emoji_events : Icons.flag,
                    color: color,
                  ),
                  const SizedBox(width: Gaps.s),
                  Expanded(
                    child: Text(
                      goal.title,
                      style: theme.textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${(progress.fraction * 100).round()}%',
                    style: theme.textTheme.titleMedium?.copyWith(color: color),
                  ),
                ],
              ),
              const SizedBox(height: Gaps.s),
              LinearProgressIndicator(
                value: progress.fraction,
                minHeight: 8,
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: Gaps.s),
              Text(
                '${formatAmount(progress.current)} / '
                '${formatAmount(goal.target, goal.unit)} · '
                '${l10n.goalDeadline(DateFormat.yMMMd(locale).format(goal.deadline))}',
                style: theme.textTheme.bodySmall,
              ),
              Text(
                goalStatusText(progress, l10n),
                style: theme.textTheme.bodySmall?.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
