import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/metric.dart';

part 'metric_model.g.dart';

@JsonSerializable()
class MetricModel {
  const MetricModel({
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

  factory MetricModel.fromJson(Map<String, dynamic> json) =>
      _$MetricModelFromJson(json);

  factory MetricModel.fromEntity(Metric m) => MetricModel(
    id: m.id,
    name: m.name,
    unit: m.unit,
    icon: m.icon,
    startValue: m.startValue,
    maxGainPerDay: m.maxGainPerDay,
    maxLossPerDay: m.maxLossPerDay,
    mode: m.mode,
    sortOrder: m.sortOrder,
  );

  final String id;
  final String name;
  final String unit;
  @JsonKey(unknownEnumValue: MetricIcon.star)
  final MetricIcon icon;
  final double startValue;
  final double maxGainPerDay;
  final double maxLossPerDay;
  @JsonKey(unknownEnumValue: MetricMode.absolute)
  final MetricMode mode;
  final int sortOrder;

  Map<String, dynamic> toJson() => _$MetricModelToJson(this);

  Metric toEntity() => Metric(
    id: id,
    name: name,
    unit: unit,
    icon: icon,
    startValue: startValue,
    maxGainPerDay: maxGainPerDay,
    maxLossPerDay: maxLossPerDay,
    mode: mode,
    sortOrder: sortOrder,
  );
}

@JsonSerializable()
class HabitMetricRuleModel {
  const HabitMetricRuleModel({
    required this.habitId,
    required this.metricId,
    this.reward = 0,
    this.penalty = 0,
  });

  factory HabitMetricRuleModel.fromJson(Map<String, dynamic> json) =>
      _$HabitMetricRuleModelFromJson(json);

  factory HabitMetricRuleModel.fromEntity(HabitMetricRule r) =>
      HabitMetricRuleModel(
        habitId: r.habitId,
        metricId: r.metricId,
        reward: r.reward,
        penalty: r.penalty,
      );

  final String habitId;
  final String metricId;
  final double reward;
  final double penalty;

  Map<String, dynamic> toJson() => _$HabitMetricRuleModelToJson(this);

  HabitMetricRule toEntity() => HabitMetricRule(
    habitId: habitId,
    metricId: metricId,
    reward: reward,
    penalty: penalty,
  );
}
