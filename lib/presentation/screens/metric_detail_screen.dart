import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/metric.dart';
import '../../domain/services/metric_calculator.dart';
import '../../l10n/generated/app_localizations.dart';
import '../blocs/habits/habits_bloc.dart';
import '../blocs/metrics/metrics_cubit.dart';
import '../router/app_router.dart';
import '../widgets/habit_visuals.dart';
import '../widgets/metric_chart.dart';
import '../widgets/metric_visuals.dart';

/// Экран метрики: текущее значение, график и история по дням
/// (вклад, прирост, потеря, итог).
class MetricDetailScreen extends StatelessWidget {
  const MetricDetailScreen({super.key, required this.metricId});

  final String metricId;

  Future<void> _delete(BuildContext context, Metric metric) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<MetricsCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle(metric.name)),
        content: Text(l10n.metricDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.pop();
      await cubit.deleteMetric(metric.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final state = context.watch<MetricsCubit>().state;
    final metric = state.byId(metricId);
    if (metric == null) return const Scaffold();
    final report =
        state.reports[metricId] ?? MetricReport(metric: metric, days: const []);
    final days = report.days.reversed.toList(); // новые сверху
    final habits = context.select((HabitsBloc b) => b.state.habits);
    final rules = state.rules.where((r) => r.metricId == metricId).toList();
    final locale = Localizations.localeOf(context).toLanguageTag();
    final value = report.currentValue;

    final header = <Widget>[
      Card(
        child: Padding(
          padding: const EdgeInsets.all(Gaps.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(metric.icon.iconData, color: theme.colorScheme.primary),
                  const SizedBox(width: Gaps.s),
                  Text(
                    formatMetric(value, metric),
                    key: const Key('metricValue'),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: value < 0 ? theme.colorScheme.error : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Gaps.xs),
              Text(
                '${metric.mode.label(l10n)} · '
                '${l10n.metricLimits(formatMetric(metric.maxGainPerDay, metric), formatMetric(metric.maxLossPerDay, metric))} · '
                '${l10n.metricStart(formatMetric(metric.startValue, metric))}',
                style: theme.textTheme.bodySmall,
              ),
              if (report.days.isNotEmpty) ...[
                const SizedBox(height: Gaps.m),
                MetricChart(
                  values: [
                    metric.startValue,
                    for (final d in report.days) d.value,
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      const SizedBox(height: Gaps.m),
      Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(Gaps.m, Gaps.m, Gaps.m, 0),
              child: Text(
                l10n.metricLinkedHabits,
                style: theme.textTheme.titleMedium,
              ),
            ),
            if (rules.isEmpty) ListTile(title: Text(l10n.metricNoLinkedHabits)),
            for (final r in rules)
              for (final h in habits.where((h) => h.id == r.habitId))
                ListTile(
                  leading: Icon(h.icon.iconData, color: h.color),
                  title: Text(h.title),
                  subtitle: Text(
                    '✔ +${formatMetric(r.reward, metric)}   '
                    '✘ −${formatMetric(r.penalty, metric)}',
                  ),
                  onTap: () => context.pushNamed(
                    AppRoutes.habitEdit,
                    pathParameters: {'id': h.id},
                  ),
                ),
          ],
        ),
      ),
      const SizedBox(height: Gaps.m),
      Text(l10n.metricHistory, style: theme.textTheme.titleMedium),
      const SizedBox(height: Gaps.s),
      if (days.isEmpty)
        Padding(
          padding: const EdgeInsets.all(Gaps.m),
          child: Text(l10n.metricHistoryEmpty),
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(metric.name),
        actions: [
          IconButton(
            tooltip: l10n.edit,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.pushNamed(
              AppRoutes.metricEdit,
              pathParameters: {'metricId': metricId},
            ),
          ),
          IconButton(
            tooltip: l10n.delete,
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _delete(context, metric),
          ),
        ],
      ),
      // ListView.builder: история может быть длинной (сотни дней),
      // строятся только видимые строки.
      body: ListView.builder(
        padding: const EdgeInsets.all(Gaps.m),
        itemCount: header.length + days.length,
        itemBuilder: (context, i) {
          if (i < header.length) return header[i];
          final d = days[i - header.length];
          final contribution = metric.mode == MetricMode.proportional
              ? '${formatAmount(d.points)} / ${formatAmount(d.maxPoints)}'
              : formatAmount(d.points);
          return _HistoryTile(
            date: DateFormat.MMMEd(locale).format(d.date),
            net: formatDelta(d.net, metric),
            netColor: deltaColor(context, d.net),
            details:
                '${l10n.metricColContribution}: $contribution · '
                '${l10n.metricColGain}: ${formatDelta(d.gain, metric)} · '
                '${l10n.metricColLoss}: ${d.loss == 0 ? '0' : '−${formatMetric(d.loss, metric)}'}',
            value: formatMetric(d.value, metric),
          );
        },
      ),
    );
  }
}

/// Строка истории за день: итог дня крупно, вклад / прирост / потеря —
/// второй строкой (на узком экране суммы не обрезаются).
class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.date,
    required this.net,
    required this.netColor,
    required this.details,
    required this.value,
  });

  final String date;
  final String net;
  final Color netColor;
  final String details;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: Gaps.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(date, style: theme.textTheme.titleSmall)),
              Text(
                net,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: netColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Text(
            '$details → $value',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
