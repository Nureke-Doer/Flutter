import '../entities/metric.dart';

/// Метрики геймификации и связи «привычка → метрика».
abstract interface class MetricRepository {
  /// Метрики, отсортированные по `sortOrder`.
  Stream<List<Metric>> watchMetrics();

  Stream<List<HabitMetricRule>> watchRules();

  Future<void> saveMetric(Metric metric);

  /// Удаляет метрику вместе со всеми её связями.
  Future<void> deleteMetric(String id);

  /// Заменяет все связи привычки: [rules] — новый полный список
  /// (пустой список — привычка ни на что не влияет).
  Future<void> setRulesForHabit(String habitId, List<HabitMetricRule> rules);
}
