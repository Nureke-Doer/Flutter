import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../l10n/generated/app_localizations.dart';
import '../blocs/metrics/metrics_cubit.dart';
import '../router/app_router.dart';
import '../widgets/empty_state.dart';
import '../widgets/metric_visuals.dart';

/// Модуль «Геймификация»: список пользовательских метрик.
class MetricsScreen extends StatelessWidget {
  const MetricsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final state = context.watch<MetricsCubit>().state;
    final today = dateOnly(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: Text(l10n.metricsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('addMetric'),
        heroTag: 'metricsFab',
        onPressed: () => context.pushNamed(AppRoutes.metricNew),
        icon: const Icon(Icons.add),
        label: Text(l10n.metricAdd),
      ),
      body: state.metrics.isEmpty
          ? EmptyState(
              icon: Icons.sports_esports_outlined,
              title: l10n.metricsEmpty,
              message: l10n.metricsEmptyHint,
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(Gaps.m, Gaps.s, Gaps.m, 96),
              itemCount: state.metrics.length + 1,
              itemBuilder: (context, i) {
                if (i == state.metrics.length) {
                  return Padding(
                    padding: const EdgeInsets.all(Gaps.s),
                    child: Text(
                      l10n.metricLossHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }
                final metric = state.metrics[i];
                final report = state.reports[metric.id];
                final value = report?.currentValue ?? metric.startValue;
                final delta = report?.netOn(today) ?? 0;
                final linked = state.rules
                    .where((r) => r.metricId == metric.id)
                    .length;
                return Card(
                  margin: const EdgeInsets.only(bottom: Gaps.s),
                  child: ListTile(
                    leading: CircleAvatar(child: Icon(metric.icon.iconData)),
                    title: Text(metric.name),
                    subtitle: Text(
                      '${metric.mode.label(l10n)} · ${l10n.metricLinkedCount(linked)}',
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formatMetric(value, metric),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: value < 0 ? theme.colorScheme.error : null,
                          ),
                        ),
                        Text(
                          formatDelta(delta, metric),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: deltaColor(context, delta),
                          ),
                        ),
                      ],
                    ),
                    onTap: () => context.pushNamed(
                      AppRoutes.metric,
                      pathParameters: {'metricId': metric.id},
                    ),
                  ),
                );
              },
            ),
    );
  }
}
