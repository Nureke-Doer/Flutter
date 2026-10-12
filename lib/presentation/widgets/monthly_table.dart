import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_history.dart';
import '../../l10n/generated/app_localizations.dart';
import 'habit_visuals.dart';

/// Таблица «по месяцам»: выполнено, срывы, сумма + полоска-график.
class MonthlyTable extends StatelessWidget {
  const MonthlyTable({
    super.key,
    required this.habit,
    required this.months,
    this.limit = 6,
  });

  final Habit habit;

  /// Итоги по месяцам (от новых к старым), см. `HabitHistory.monthly`.
  final List<MonthSummary> months;

  /// Сколько последних месяцев показывать.
  final int limit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final shown = months.take(limit).toList();
    double valueOf(MonthSummary m) =>
        habit.isNumeric ? m.amount : m.successes.toDouble();
    var maxValue = 1.0;
    for (final m in shown) {
      if (valueOf(m) > maxValue) maxValue = valueOf(m);
    }
    final header = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.outline,
    );

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2.2),
        1: FlexColumnWidth(),
        2: FlexColumnWidth(),
        3: FlexColumnWidth(2),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          children: [
            Text(l10n.monthColumn, style: header),
            Text('✔', style: header, textAlign: TextAlign.center),
            Text('✘', style: header, textAlign: TextAlign.center),
            Text(
              habit.isNumeric ? l10n.sumColumn : '',
              style: header,
              textAlign: TextAlign.end,
            ),
          ],
        ),
        for (final m in shown)
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: Gaps.s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(DateFormat.yMMM(locale).format(m.month)),
                    const SizedBox(height: Gaps.xs),
                    // Полоска — простой график по месяцам.
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: (valueOf(m) / maxValue)
                          .clamp(0.02, 1)
                          .toDouble(),
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: habit.color,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text('${m.successes}', textAlign: TextAlign.center),
              Text(
                '${m.failures}',
                textAlign: TextAlign.center,
                style: m.failures > 0
                    ? const TextStyle(color: EntryColors.failed)
                    : null,
              ),
              Text(
                habit.isNumeric ? formatAmount(m.amount, habit.unit) : '',
                textAlign: TextAlign.end,
              ),
            ],
          ),
      ],
    );
  }
}
