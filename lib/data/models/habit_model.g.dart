// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HabitModel _$HabitModelFromJson(Map<String, dynamic> json) => HabitModel(
  id: json['id'] as String,
  title: json['title'] as String,
  createdAt: json['createdAt'] as String,
  description: json['description'] as String? ?? '',
  categoryId: json['categoryId'] as String?,
  kind:
      $enumDecodeNullable(
        _$HabitKindEnumMap,
        json['kind'],
        unknownValue: HabitKind.positive,
      ) ??
      HabitKind.positive,
  icon:
      $enumDecodeNullable(
        _$HabitIconEnumMap,
        json['icon'],
        unknownValue: HabitIcon.check,
      ) ??
      HabitIcon.check,
  colorValue: (json['colorValue'] as num?)?.toInt() ?? 0xFF00897B,
  unit: json['unit'] as String?,
  target: (json['target'] as num?)?.toDouble(),
  scheduleType:
      $enumDecodeNullable(
        _$ScheduleTypeEnumMap,
        json['scheduleType'],
        unknownValue: ScheduleType.daily,
      ) ??
      ScheduleType.daily,
  weekdays:
      (json['weekdays'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [1, 2, 3, 4, 5, 6, 7],
  timesPerWeek: (json['timesPerWeek'] as num?)?.toInt() ?? 7,
  reminderMinutes: (json['reminderMinutes'] as num?)?.toInt(),
  archived: json['archived'] as bool? ?? false,
  placeId: json['placeId'] as String?,
);

Map<String, dynamic> _$HabitModelToJson(HabitModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'categoryId': instance.categoryId,
      'kind': _$HabitKindEnumMap[instance.kind]!,
      'icon': _$HabitIconEnumMap[instance.icon]!,
      'colorValue': instance.colorValue,
      'unit': instance.unit,
      'target': instance.target,
      'scheduleType': _$ScheduleTypeEnumMap[instance.scheduleType]!,
      'weekdays': instance.weekdays,
      'timesPerWeek': instance.timesPerWeek,
      'reminderMinutes': instance.reminderMinutes,
      'archived': instance.archived,
      'placeId': instance.placeId,
      'createdAt': instance.createdAt,
    };

const _$HabitKindEnumMap = {
  HabitKind.positive: 'positive',
  HabitKind.quit: 'quit',
  HabitKind.numeric: 'numeric',
};

const _$HabitIconEnumMap = {
  HabitIcon.check: 'check',
  HabitIcon.water: 'water',
  HabitIcon.run: 'run',
  HabitIcon.book: 'book',
  HabitIcon.code: 'code',
  HabitIcon.language: 'language',
  HabitIcon.math: 'math',
  HabitIcon.meditation: 'meditation',
  HabitIcon.sleep: 'sleep',
  HabitIcon.music: 'music',
  HabitIcon.science: 'science',
  HabitIcon.art: 'art',
  HabitIcon.gym: 'gym',
  HabitIcon.walk: 'walk',
  HabitIcon.food: 'food',
  HabitIcon.noSmoking: 'noSmoking',
  HabitIcon.phone: 'phone',
  HabitIcon.money: 'money',
};

const _$ScheduleTypeEnumMap = {
  ScheduleType.daily: 'daily',
  ScheduleType.weekdays: 'weekdays',
  ScheduleType.timesPerWeek: 'timesPerWeek',
};
