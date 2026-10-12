// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HabitModel _$HabitModelFromJson(Map<String, dynamic> json) => HabitModel(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  type: $enumDecode(
    _$HabitTypeEnumMap,
    json['type'],
    unknownValue: HabitType.habit,
  ),
  icon: $enumDecode(
    _$HabitIconEnumMap,
    json['icon'],
    unknownValue: HabitIcon.check,
  ),
  colorValue: (json['colorValue'] as num).toInt(),
  weekdays: (json['weekdays'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
  completedDays: (json['completedDays'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  createdAt: json['createdAt'] as String,
  reminderMinutes: (json['reminderMinutes'] as num?)?.toInt(),
  targetMinutes: (json['targetMinutes'] as num?)?.toInt(),
);

Map<String, dynamic> _$HabitModelToJson(HabitModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'type': _$HabitTypeEnumMap[instance.type]!,
      'icon': _$HabitIconEnumMap[instance.icon]!,
      'colorValue': instance.colorValue,
      'weekdays': instance.weekdays,
      'reminderMinutes': instance.reminderMinutes,
      'targetMinutes': instance.targetMinutes,
      'completedDays': instance.completedDays,
      'createdAt': instance.createdAt,
    };

const _$HabitTypeEnumMap = {HabitType.habit: 'habit', HabitType.study: 'study'};

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
};
