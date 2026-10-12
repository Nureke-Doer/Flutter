import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'habit_visuals.dart';

/// Простая столбчатая диаграмма из `Container`-ов (без сторонних библиотек).
class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({super.key, required this.days, required this.values});

  /// Даты столбцов.
  final List<DateTime> days;

  /// Значения 0.0–1.0 для каждого дня.
  final List<double> values;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const maxBarHeight = 120.0;
    return SizedBox(
      height: maxBarHeight + 44,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < days.length; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Gaps.xs),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${(values[i] * 100).round()}%',
                      style: theme.textTheme.labelSmall,
                    ),
                    const SizedBox(height: Gaps.xs),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      height: 4 + values[i] * (maxBarHeight - 4),
                      decoration: BoxDecoration(
                        color: i == days.length - 1
                            ? theme.colorScheme.primary
                            : theme.colorScheme.primary.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: Gaps.xs),
                    Text(
                      weekdayShort(context, days[i].weekday),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
