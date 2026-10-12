import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils.dart';
import '../blocs/metrics/metrics_cubit.dart';
import '../providers/settings_notifier.dart';
import '../router/app_router.dart';
import 'metric_visuals.dart';

/// Компактная плашка с текущими значениями метрик (и изменением за день).
///
/// Показывается только если модуль «Геймификация» включён и есть метрики —
/// иначе это пустой виджет, и в интерфейсе нет упоминаний метрик.
class MetricsStrip extends StatelessWidget {
  const MetricsStrip({super.key, this.day, this.navigable = true});

  /// День, за который показывать изменение (по умолчанию — сегодня).
  final DateTime? day;

  /// Нажатие открывает экран метрики.
  final bool navigable;

  @override
  Widget build(BuildContext context) {
    final enabled = context.select(
      (SettingsNotifier s) => s.gamificationEnabled,
    );
    if (!enabled) return const SizedBox.shrink();
    final state = context.watch<MetricsCubit>().state;
    if (state.metrics.isEmpty) return const SizedBox.shrink();
    final date = dateOnly(day ?? DateTime.now());

    return Padding(
      padding: const EdgeInsets.only(top: Gaps.s),
      child: Wrap(
        key: const Key('metricsStrip'),
        spacing: Gaps.s,
        runSpacing: Gaps.xs,
        children: [
          for (final metric in state.metrics)
            Builder(
              builder: (context) {
                final report = state.reports[metric.id];
                final value = report?.currentValue ?? metric.startValue;
                final delta = report?.netOn(date) ?? 0;
                final avatar = Icon(metric.icon.iconData, size: 18);
                final label = Text.rich(
                  TextSpan(
                    text: '${metric.name}: ${formatMetric(value, metric)}',
                    children: [
                      if (delta != 0)
                        TextSpan(
                          text: '  ${formatDelta(delta, metric)}',
                          style: TextStyle(color: deltaColor(context, delta)),
                        ),
                    ],
                  ),
                );
                if (!navigable) return Chip(avatar: avatar, label: label);
                return ActionChip(
                  avatar: avatar,
                  label: label,
                  onPressed: () => context.pushNamed(
                    AppRoutes.metric,
                    pathParameters: {'metricId': metric.id},
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
