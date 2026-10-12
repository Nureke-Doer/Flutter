import 'dart:math' as math;

import 'package:equatable/equatable.dart';

import '../../core/utils/date_utils.dart';
import '../entities/habit.dart';
import '../entities/habit_entry.dart';
import '../entities/habit_history.dart';
import '../entities/metric.dart';

/// Расчёт метрики за один день.
class MetricDay extends Equatable {
  const MetricDay({
    required this.date,
    required this.points,
    required this.maxPoints,
    required this.penalties,
    required this.gain,
    required this.loss,
    required this.value,
  });

  final DateTime date;

  /// Вклад: сумма наград за выполненные привычки.
  final double points;

  /// Максимум возможных очков (для пропорционального режима).
  final double maxPoints;

  /// Сумма штрафов за ✘ (до применения лимита).
  final double penalties;

  /// Прирост за день (уже с учётом лимита).
  final double gain;

  /// Потеря за день (уже с учётом лимита).
  final double loss;

  /// Значение метрики на конец дня.
  final double value;

  /// Итог дня: прирост − потеря.
  double get net => gain - loss;

  @override
  List<Object?> get props => [
    date,
    points,
    maxPoints,
    penalties,
    gain,
    loss,
    value,
  ];
}

/// История метрики по дням и текущее значение.
class MetricReport extends Equatable {
  const MetricReport({required this.metric, required this.days});

  final Metric metric;

  /// Дни, в которые была хотя бы одна отметка привязанных привычек
  /// (по возрастанию даты). В остальные дни метрика не меняется.
  final List<MetricDay> days;

  double get currentValue => days.isEmpty ? metric.startValue : days.last.value;

  /// Итог за конкретный день (0, если отметок не было).
  double netOn(DateTime day) {
    for (final d in days.reversed) {
      if (isSameDay(d.date, day)) return d.net;
      if (d.date.isBefore(day)) break;
    }
    return 0;
  }

  @override
  List<Object?> get props => [metric, days];
}

/// Расчёт метрик модуля «Геймификация» (чистая функция, без состояния).
///
/// Правила из ТЗ:
/// - **пропорциональный** режим: прирост = лимит × (очки дня / максимум
///   возможных очков);
/// - **абсолютный** режим: прирост = MIN(лимит, сумма наград);
/// - потеря в обоих режимах = MIN(лимит потери, сумма штрафов за ✘);
/// - значение = старт + Σ(прирост − потеря), может уходить в минус;
/// - 0 (пропуск) и пустые дни ни на что не влияют.
///
/// Значения не хранятся, а каждый раз считаются из отметок, поэтому
/// при изменении наград/штрафов история пересчитывается автоматически.
abstract final class MetricCalculator {
  static MetricReport calculate({
    required Metric metric,
    required List<HabitMetricRule> rules,
    required List<Habit> habits,
    required Map<String, HabitHistory> histories,
  }) {
    final habitById = {for (final h in habits) h.id: h};
    // Только связи этой метрики с существующими привычками.
    final linked = [
      for (final r in rules)
        if (r.metricId == metric.id && habitById.containsKey(r.habitId)) r,
    ];

    // Дни, в которые отмечена хотя бы одна привязанная привычка.
    final dates = <DateTime>{
      for (final r in linked) ...?histories[r.habitId]?.days,
    }.toList()..sort();

    var value = metric.startValue;
    final days = <MetricDay>[];
    for (final date in dates) {
      var points = 0.0;
      var maxPoints = 0.0;
      var penalties = 0.0;
      for (final rule in linked) {
        final habit = habitById[rule.habitId]!;
        final entry = histories[rule.habitId]?.valueOn(date);
        if (entry != null && entry.isSuccess) points += rule.reward;
        if (entry != null && entry.isFailure) penalties += rule.penalty;
        if (_countsInMax(habit, entry, date)) maxPoints += rule.reward;
      }

      final gain = switch (metric.mode) {
        MetricMode.proportional =>
          maxPoints <= 0 ? 0.0 : metric.maxGainPerDay * (points / maxPoints),
        MetricMode.absolute => math.min(metric.maxGainPerDay, points),
      };
      final loss = math.min(metric.maxLossPerDay, penalties);
      value += gain - loss;
      days.add(
        MetricDay(
          date: date,
          points: points,
          maxPoints: maxPoints,
          penalties: penalties,
          gain: gain,
          loss: loss,
          value: value,
        ),
      );
    }
    return MetricReport(metric: metric, days: days);
  }

  /// Входит ли награда привычки в «максимум возможных очков» дня.
  ///
  /// - отмечена ✔/✘/числом — да;
  /// - пропуск (0) — нет: пропуск ни на что не влияет;
  /// - пусто — да, если привычка активна, уже создана и запланирована
  ///   на этот день (не сделал — недобрал очки). Для «N раз в неделю»
  ///   и архивных пустой день не считается.
  static bool _countsInMax(Habit habit, EntryValue? entry, DateTime date) {
    if (entry != null) return !entry.isNeutral;
    return !habit.archived &&
        habit.schedule.type != ScheduleType.timesPerWeek &&
        habit.isScheduledOn(date) &&
        !date.isBefore(dateOnly(habit.createdAt));
  }
}
