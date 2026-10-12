import '../../domain/entities/metric.dart';
import '../../domain/repositories/metric_repository.dart';
import '../datasources/local/local_collection.dart';
import '../models/metric_model.dart';

/// Метрики и связи в Hive (две коллекции).
class HiveMetricRepository implements MetricRepository {
  HiveMetricRepository({
    required LocalCollection metrics,
    required LocalCollection rules,
  }) : _metrics = metrics,
       _rules = rules;

  final LocalCollection _metrics;
  final LocalCollection _rules;

  static List<T> _parse<T>(
    List<Map<String, dynamic>> raw,
    T Function(Map<String, dynamic>) parse,
  ) {
    final list = <T>[];
    for (final json in raw) {
      try {
        list.add(parse(json));
      } on Object {
        continue;
      }
    }
    return list;
  }

  @override
  Stream<List<Metric>> watchMetrics() => _metrics.watch().map(
    (raw) => List.unmodifiable(
      _parse(raw, (j) => MetricModel.fromJson(j).toEntity())
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)),
    ),
  );

  @override
  Stream<List<HabitMetricRule>> watchRules() => _rules.watch().map(
    (raw) => List.unmodifiable(
      _parse(raw, (j) => HabitMetricRuleModel.fromJson(j).toEntity()),
    ),
  );

  @override
  Future<void> saveMetric(Metric metric) =>
      _metrics.put(metric.id, MetricModel.fromEntity(metric).toJson());

  @override
  Future<void> deleteMetric(String id) async {
    await _rules.deleteWhere((json) => json['metricId'] == id);
    await _metrics.delete(id);
  }

  @override
  Future<void> setRulesForHabit(
    String habitId,
    List<HabitMetricRule> rules,
  ) async {
    final keep = {for (final r in rules) r.key};
    await _rules.deleteWhere(
      (json) =>
          json['habitId'] == habitId &&
          !keep.contains('$habitId|${json['metricId']}'),
    );
    if (rules.isEmpty) return;
    await _rules.putAll({
      for (final r in rules) r.key: HabitMetricRuleModel.fromEntity(r).toJson(),
    });
  }
}
