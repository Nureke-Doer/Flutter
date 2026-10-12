import 'package:flutter/material.dart';

import '../../domain/entities/metric.dart';
import '../../l10n/generated/app_localizations.dart';
import 'habit_visuals.dart';

extension MetricIconX on MetricIcon {
  IconData get iconData => switch (this) {
    MetricIcon.power => Icons.bolt,
    MetricIcon.money => Icons.payments_outlined,
    MetricIcon.star => Icons.star_outline,
    MetricIcon.heart => Icons.favorite_outline,
    MetricIcon.brain => Icons.psychology_outlined,
    MetricIcon.bolt => Icons.flash_on,
    MetricIcon.trophy => Icons.emoji_events_outlined,
    MetricIcon.leaf => Icons.eco_outlined,
  };
}

extension MetricModeX on MetricMode {
  String label(AppLocalizations l10n) => switch (this) {
    MetricMode.proportional => l10n.metricModeProportional,
    MetricMode.absolute => l10n.metricModeAbsolute,
  };

  String hint(AppLocalizations l10n) => switch (this) {
    MetricMode.proportional => l10n.metricModeProportionalHint,
    MetricMode.absolute => l10n.metricModeAbsoluteHint,
  };
}

/// Значение метрики с единицей: «12,5 %», «-300 000 тг».
String formatMetric(double value, Metric metric) {
  final rounded = (value * 100).roundToDouble() / 100;
  return formatAmount(rounded, metric.unit);
}

/// Изменение со знаком: «+1 %», «−50 %».
String formatDelta(double value, Metric metric) {
  if (value == 0) return formatMetric(0, metric);
  final sign = value > 0 ? '+' : '−';
  return '$sign${formatMetric(value.abs(), metric)}';
}

Color deltaColor(BuildContext context, double value) => value > 0
    ? Colors.green.shade700
    : value < 0
    ? Theme.of(context).colorScheme.error
    : Theme.of(context).colorScheme.outline;
