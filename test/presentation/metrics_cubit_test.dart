import 'package:flutter_test/flutter_test.dart';
import 'package:habit_study_tracker/data/datasources/local/hive_storage.dart';
import 'package:habit_study_tracker/data/repositories/hive_metric_repository.dart';
import 'package:habit_study_tracker/data/repositories/in_memory_habit_repository.dart';
import 'package:habit_study_tracker/domain/entities/habit.dart';
import 'package:habit_study_tracker/domain/entities/habit_entry.dart';
import 'package:habit_study_tracker/domain/entities/metric.dart';
import 'package:habit_study_tracker/presentation/blocs/metrics/metrics_cubit.dart';

import '../helpers/hive_test_utils.dart';

void main() {
  final day = DateTime(2026, 9, 9);
  late HiveMetricRepository metrics;
  late InMemoryHabitRepository habits;
  late MetricsCubit cubit;

  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 20));

  setUp(() async {
    await setUpTestHive();
    metrics = HiveMetricRepository(
      metrics: testCollection(HiveBoxes.metrics),
      rules: testCollection(HiveBoxes.metricRules),
    );
    habits = InMemoryHabitRepository(
      initial: [Habit(id: 'sport', title: 'Спорт', createdAt: day)],
      entries: [
        HabitEntry(habitId: 'sport', date: day, value: const EntryDone()),
      ],
    );
    cubit = MetricsCubit(metricRepository: metrics, habitRepository: habits);
    await settle();
  });

  tearDown(() async {
    await cubit.close();
    await tearDownTestHive();
  });

  test('считает метрику и пересчитывает после изменения награды', () async {
    await cubit.saveMetric(MetricPresets.money('money'));
    await cubit.setRulesForHabit('sport', [
      const HabitMetricRule(
        habitId: 'sport',
        metricId: 'money',
        reward: 1000,
        penalty: 5000,
      ),
    ]);
    await settle();
    expect(cubit.state.reports['money']!.currentValue, 1000);

    await cubit.setRulesForHabit('sport', [
      const HabitMetricRule(
        habitId: 'sport',
        metricId: 'money',
        reward: 2500,
        penalty: 5000,
      ),
    ]);
    await settle();
    expect(cubit.state.reports['money']!.currentValue, 2500);
    expect(cubit.state.rulesForHabit('sport'), hasLength(1));
  });

  test('новая отметка сразу меняет метрику', () async {
    await cubit.saveMetric(MetricPresets.money('money'));
    await cubit.setRulesForHabit('sport', [
      const HabitMetricRule(
        habitId: 'sport',
        metricId: 'money',
        reward: 100,
        penalty: 300,
      ),
    ]);
    await habits.setEntry('sport', day, const EntryFailed());
    await settle();
    expect(cubit.state.reports['money']!.currentValue, -300);
  });

  test('удаление метрики удаляет и её связи; пустой список связей', () async {
    await cubit.saveMetric(MetricPresets.power('power'));
    await cubit.setRulesForHabit('sport', [
      const HabitMetricRule(habitId: 'sport', metricId: 'power', reward: 1),
    ]);
    await settle();
    expect(cubit.state.rules, hasLength(1));

    await cubit.setRulesForHabit('sport', const []);
    await settle();
    expect(cubit.state.rules, isEmpty);

    await cubit.setRulesForHabit('sport', [
      const HabitMetricRule(habitId: 'sport', metricId: 'power', reward: 1),
    ]);
    await cubit.deleteMetric('power');
    await settle();
    expect(cubit.state.metrics, isEmpty);
    expect(cubit.state.rules, isEmpty);
  });
}
