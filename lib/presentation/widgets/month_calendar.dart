import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/habit.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils.dart';
import 'habit_visuals.dart';

/// Календарь текущего месяца: выполненные дни закрашены цветом цели.
class MonthCalendar extends StatelessWidget {
  const MonthCalendar({super.key, required this.habit, required this.month});

  final Habit habit;

  /// Любая дата внутри отображаемого месяца.
  final DateTime month;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final first = DateTime(month.year, month.month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingEmpty = first.weekday - 1; // неделя начинается с понедельника
    final today = dateOnly(DateTime.now());
    final title = DateFormat.yMMMM(locale).format(first);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title[0].toUpperCase() + title.substring(1),
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: Gaps.s),
        Row(
          children: [
            for (var wd = 1; wd <= 7; wd++)
              Expanded(
                child: Center(
                  child: Text(
                    weekdayShort(context, wd),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: Gaps.xs),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: leadingEmpty + daysInMonth,
          itemBuilder: (context, index) {
            if (index < leadingEmpty) return const SizedBox.shrink();
            final day = DateTime(
              month.year,
              month.month,
              index - leadingEmpty + 1,
            );
            final done = habit.isCompletedOn(day);
            final isToday = isSameDay(day, today);
            final scheduled = habit.isScheduledOn(day);
            return Container(
              decoration: BoxDecoration(
                color: done
                    ? habit.color
                    : scheduled
                    ? theme.colorScheme.surfaceContainerHighest
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: isToday
                    ? Border.all(color: theme.colorScheme.primary, width: 2)
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                '${day.day}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: done ? Colors.white : null,
                  fontWeight: isToday ? FontWeight.bold : null,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
