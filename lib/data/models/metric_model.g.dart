// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metric_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MetricModel _$MetricModelFromJson(Map<String, dynamic> json) => MetricModel(
  id: json['id'] as String,
  name: json['name'] as String,
  maxGainPerDay: (json['maxGainPerDay'] as num).toDouble(),
  maxLossPerDay: (json['maxLossPerDay'] as num).toDouble(),
  unit: json['unit'] as String? ?? '',
  icon:
      $enumDecodeNullable(
        _$MetricIconEnumMap,
        json['icon'],
        unknownValue: MetricIcon.star,
      ) ??
      MetricIcon.star,
  startValue: (json['startValue'] as num?)?.toDouble() ?? 0,
  mode:
      $enumDecodeNullable(
        _$MetricModeEnumMap,
        json['mode'],
        unknownValue: MetricMode.absolute,
      ) ??
      MetricMode.absolute,
  sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$MetricModelToJson(MetricModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'unit': instance.unit,
      'icon': _$MetricIconEnumMap[instance.icon]!,
      'startValue': instance.startValue,
      'maxGainPerDay': instance.maxGainPerDay,
      'maxLossPerDay': instance.maxLossPerDay,
      'mode': _$MetricModeEnumMap[instance.mode]!,
      'sortOrder': instance.sortOrder,
    };

const _$MetricIconEnumMap = {
  MetricIcon.power: 'power',
  MetricIcon.money: 'money',
  MetricIcon.star: 'star',
  MetricIcon.heart: 'heart',
  MetricIcon.brain: 'brain',
  MetricIcon.bolt: 'bolt',
  MetricIcon.trophy: 'trophy',
  MetricIcon.leaf: 'leaf',
};

const _$MetricModeEnumMap = {
  MetricMode.proportional: 'proportional',
  MetricMode.absolute: 'absolute',
};

HabitMetricRuleModel _$HabitMetricRuleModelFromJson(
  Map<String, dynamic> json,
) => HabitMetricRuleModel(
  habitId: json['habitId'] as String,
  metricId: json['metricId'] as String,
  reward: (json['reward'] as num?)?.toDouble() ?? 0,
  penalty: (json['penalty'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$HabitMetricRuleModelToJson(
  HabitMetricRuleModel instance,
) => <String, dynamic>{
  'habitId': instance.habitId,
  'metricId': instance.metricId,
  'reward': instance.reward,
  'penalty': instance.penalty,
};
