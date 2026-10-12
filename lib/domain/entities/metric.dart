import 'package:equatable/equatable.dart';

/// Режим начисления метрики.
enum MetricMode {
  /// Как Power: прирост = лимит × (очки дня / максимум возможных очков).
  proportional,

  /// Как Money: прирост = MIN(лимит, сумма наград).
  absolute,
}

/// Иконки метрик (ключи; `IconData` подбирается в UI).
enum MetricIcon { power, money, star, heart, brain, bolt, trophy, leaf }

/// Пользовательская метрика модуля «Геймификация».
///
/// Пользователь сам создаёт любое количество метрик с любыми названиями.
/// Значение = [startValue] + сумма (прирост − потеря) по всем дням
/// и может уходить в минус.
class Metric extends Equatable {
  const Metric({
    required this.id,
    required this.name,
    required this.maxGainPerDay,
    required this.maxLossPerDay,
    this.unit = '',
    this.icon = MetricIcon.star,
    this.startValue = 0,
    this.mode = MetricMode.absolute,
    this.sortOrder = 0,
  });

  final String id;
  final String name;

  /// Единица или валюта: «%», «тг», «XP».
  final String unit;
  final MetricIcon icon;
  final double startValue;

  /// Лимит прироста в день (> 0).
  final double maxGainPerDay;

  /// Лимит потери в день (> 0).
  final double maxLossPerDay;
  final MetricMode mode;
  final int sortOrder;

  Metric copyWith({
    String? name,
    String? unit,
    MetricIcon? icon,
    double? startValue,
    double? maxGainPerDay,
    double? maxLossPerDay,
    MetricMode? mode,
    int? sortOrder,
  }) => Metric(
    id: id,
    name: name ?? this.name,
    unit: unit ?? this.unit,
    icon: icon ?? this.icon,
    startValue: startValue ?? this.startValue,
    maxGainPerDay: maxGainPerDay ?? this.maxGainPerDay,
    maxLossPerDay: maxLossPerDay ?? this.maxLossPerDay,
    mode: mode ?? this.mode,
    sortOrder: sortOrder ?? this.sortOrder,
  );

  @override
  List<Object?> get props => [
    id,
    name,
    unit,
    icon,
    startValue,
    maxGainPerDay,
    maxLossPerDay,
    mode,
    sortOrder,
  ];
}

/// Готовые пресеты (пользователь может их не использовать).
abstract final class MetricPresets {
  /// Power (%): прирост пропорционально выполненному, макс. +1% в день,
  /// макс. −50% в день, старт 0%.
  static Metric power(String id) => Metric(
    id: id,
    name: 'Power',
    unit: '%',
    icon: MetricIcon.power,
    maxGainPerDay: 1,
    maxLossPerDay: 50,
    mode: MetricMode.proportional,
  );

  /// Money (тг): фиксированные награды/штрафы, макс. +300 000 в день,
  /// макс. −1 000 000 в день, старт 0.
  static Metric money(String id) => Metric(
    id: id,
    name: 'Money',
    unit: 'тг',
    icon: MetricIcon.money,
    maxGainPerDay: 300000,
    maxLossPerDay: 1000000,
  );
}

/// Связь «привычка → метрика»: награда за ✔ и штраф за ✘.
///
/// Связь необязательна: привычка без связей на метрики не влияет.
class HabitMetricRule extends Equatable {
  const HabitMetricRule({
    required this.habitId,
    required this.metricId,
    this.reward = 0,
    this.penalty = 0,
  });

  final String habitId;
  final String metricId;

  /// Сколько начисляется за выполнение (✔ или число > 0).
  final double reward;

  /// Сколько списывается за ✘.
  final double penalty;

  /// Ключ в хранилище: одна связь на пару привычка–метрика.
  String get key => '$habitId|$metricId';

  HabitMetricRule copyWith({double? reward, double? penalty}) =>
      HabitMetricRule(
        habitId: habitId,
        metricId: metricId,
        reward: reward ?? this.reward,
        penalty: penalty ?? this.penalty,
      );

  @override
  List<Object?> get props => [habitId, metricId, reward, penalty];
}
