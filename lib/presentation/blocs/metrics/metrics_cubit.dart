import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/habit.dart';
import '../../../domain/entities/habit_entry.dart';
import '../../../domain/entities/habit_history.dart';
import '../../../domain/entities/metric.dart';
import '../../../domain/repositories/habit_repository.dart';
import '../../../domain/repositories/metric_repository.dart';
import '../../../domain/services/metric_calculator.dart';

/// Состояние модуля «Геймификация».
class MetricsState extends Equatable {
  const MetricsState({
    this.metrics = const [],
    this.rules = const [],
    this.reports = const {},
  });

  final List<Metric> metrics;
  final List<HabitMetricRule> rules;

  /// Рассчитанная история каждой метрики (по id метрики).
  final Map<String, MetricReport> reports;

  Metric? byId(String id) {
    for (final m in metrics) {
      if (m.id == id) return m;
    }
    return null;
  }

  List<HabitMetricRule> rulesForHabit(String habitId) =>
      rules.where((r) => r.habitId == habitId).toList();

  @override
  List<Object?> get props => [metrics, rules, reports];
}

/// Метрики, связи с привычками и их пересчёт.
///
/// Слушает четыре потока (метрики, связи, привычки, отметки) и после
/// любого изменения пересчитывает отчёты через [MetricCalculator].
/// Поэтому изменение награды или штрафа сразу пересчитывает всю историю.
class MetricsCubit extends Cubit<MetricsState> {
  MetricsCubit({
    required MetricRepository metricRepository,
    required HabitRepository habitRepository,
  }) : _repository = metricRepository,
       super(const MetricsState()) {
    _subscriptions = [
      metricRepository.watchMetrics().listen((m) {
        _metrics = m;
        _recalculate();
      }),
      metricRepository.watchRules().listen((r) {
        _rules = r;
        _recalculate();
      }),
      habitRepository.watchHabits().listen((h) {
        _habits = h;
        _recalculate();
      }),
      habitRepository.watchEntries().listen((e) {
        _histories = _group(e);
        _recalculate();
      }),
    ];
  }

  final MetricRepository _repository;
  late final List<StreamSubscription<Object?>> _subscriptions;

  List<Metric> _metrics = const [];
  List<HabitMetricRule> _rules = const [];
  List<Habit> _habits = const [];
  Map<String, HabitHistory> _histories = const {};

  static Map<String, HabitHistory> _group(List<HabitEntry> entries) {
    final byHabit = <String, Map<DateTime, EntryValue>>{};
    for (final e in entries) {
      (byHabit[e.habitId] ??= {})[e.date] = e.value;
    }
    return {for (final e in byHabit.entries) e.key: HabitHistory(e.value)};
  }

  void _recalculate() {
    if (isClosed) return;
    emit(
      MetricsState(
        metrics: _metrics,
        rules: _rules,
        reports: {
          for (final m in _metrics)
            m.id: MetricCalculator.calculate(
              metric: m,
              rules: _rules,
              habits: _habits,
              histories: _histories,
            ),
        },
      ),
    );
  }

  Future<void> saveMetric(Metric metric) => _repository.saveMetric(metric);

  Future<void> deleteMetric(String id) => _repository.deleteMetric(id);

  Future<void> setRulesForHabit(String habitId, List<HabitMetricRule> rules) =>
      _repository.setRulesForHabit(habitId, rules);

  @override
  Future<void> close() async {
    for (final s in _subscriptions) {
      await s.cancel();
    }
    return super.close();
  }
}
