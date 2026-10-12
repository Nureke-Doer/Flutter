import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_entry.dart';
import '../../domain/entities/habit_history.dart';
import 'habit_visuals.dart';

/// Цвет ячейки календаря для значения отметки.
///
/// Для числовой привычки с целью яркость зависит от доли выполнения
/// (тепловая карта), для остальных ✔ — цвет привычки, ✘ — красный.
Color? entryCellColor(Habit habit, EntryValue? value, ColorScheme scheme) {
  return switch (value) {
    null => null,
    EntryFailed() => EntryColors.failed,
    EntrySkipped() => scheme.outlineVariant,
    EntryDone() => habit.color,
    EntryAmount(:final amount) when amount <= 0 => scheme.outlineVariant,
    EntryAmount(:final amount) => habit.color.withValues(
      alpha: habit.target == null || habit.target! <= 0
          ? 1
          : (0.35 + 0.65 * (amount / habit.target!).clamp(0, 1)),
    ),
  };
}

/// Календарь месяца с отметками. Стрелками листаются месяцы,
/// нажатие на прошедший день позволяет изменить отметку.
class MonthCalendar extends StatefulWidget {
  const MonthCalendar({
    super.key,
    required this.habit,
    required this.history,
    required this.today,
    this.onDayTap,
  });

  final Habit habit;
  final HabitHistory history;
  final DateTime today;
  final ValueChanged<DateTime>? onDayTap;

  @override
  State<MonthCalendar> createState() => _MonthCalendarState();
}

class _MonthCalendarState extends State<MonthCalendar> {
  late DateTime _month = startOfMonth(widget.today);

  void _shift(int months) =>
      setState(() => _month = DateTime(_month.year, _month.month + months));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final leadingEmpty = _month.weekday - 1; // неделя начинается с понедельника
    final title = DateFormat.yMMMM(locale).format(_month);
    final isCurrentMonth = _month == startOfMonth(widget.today);

    // На широком экране календарь не растягивается — ячейки остаются
    // компактными.
    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: _buildMonth(
          context,
          theme,
          title,
          daysInMonth,
          leadingEmpty,
          isCurrentMonth,
        ),
      ),
    );
  }

  Widget _buildMonth(
    BuildContext context,
    ThemeData theme,
    String title,
    int daysInMonth,
    int leadingEmpty,
    bool isCurrentMonth,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title[0].toUpperCase() + title.substring(1),
                style: theme.textTheme.titleSmall,
              ),
            ),
            IconButton(
              key: const Key('prevMonth'),
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.chevron_left),
              onPressed: () => _shift(-1),
            ),
            IconButton(
              key: const Key('nextMonth'),
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.chevron_right),
              onPressed: isCurrentMonth ? null : () => _shift(1),
            ),
          ],
        ),
        const SizedBox(height: Gaps.xs),
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
              _month.year,
              _month.month,
              index - leadingEmpty + 1,
            );
            final value = widget.history.valueOn(day);
            final fill = entryCellColor(widget.habit, value, theme.colorScheme);
            final isToday = isSameDay(day, widget.today);
            final isFuture = day.isAfter(widget.today);
            final scheduled = widget.habit.isScheduledOn(day);
            return InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: isFuture || widget.onDayTap == null
                  ? null
                  : () => widget.onDayTap!(day),
              child: Container(
                decoration: BoxDecoration(
                  color:
                      fill ??
                      (scheduled && !isFuture
                          ? theme.colorScheme.surfaceContainerHighest
                          : Colors.transparent),
                  borderRadius: BorderRadius.circular(8),
                  border: isToday
                      ? Border.all(color: theme.colorScheme.primary, width: 2)
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${day.day}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: (value?.isSuccess ?? false) || value is EntryFailed
                        ? Colors.white
                        : isFuture
                        ? theme.colorScheme.outline
                        : null,
                    fontWeight: isToday ? FontWeight.bold : null,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Тепловая карта за последние [weeks] недель (как на GitHub):
/// колонки — недели, строки — дни недели.
class CalendarHeatmap extends StatelessWidget {
  const CalendarHeatmap({
    super.key,
    required this.habit,
    required this.history,
    required this.today,
    this.weeks = 20,
  });

  final Habit habit;
  final HabitHistory history;
  final DateTime today;
  final int weeks;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final firstMonday = addDays(startOfWeek(today), -7 * (weeks - 1));
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 3.0;
        final cell = ((constraints.maxWidth - gap * (weeks - 1)) / weeks).clamp(
          4.0,
          18.0,
        );
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            for (var w = 0; w < weeks; w++)
              Padding(
                padding: EdgeInsets.only(left: w == 0 ? 0 : gap),
                child: Column(
                  children: [
                    for (var d = 0; d < 7; d++)
                      _cell(addDays(firstMonday, w * 7 + d), cell, gap, scheme),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _cell(DateTime day, double size, double gap, ColorScheme scheme) {
    final future = day.isAfter(today);
    final color = future
        ? Colors.transparent
        : entryCellColor(habit, history.valueOn(day), scheme) ??
              scheme.surfaceContainerHighest;
    return Container(
      width: size,
      height: size,
      margin: EdgeInsets.only(bottom: gap),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
