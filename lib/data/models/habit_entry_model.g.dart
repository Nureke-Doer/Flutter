// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_entry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HabitEntryModel _$HabitEntryModelFromJson(Map<String, dynamic> json) =>
    HabitEntryModel(
      habitId: json['habitId'] as String,
      date: json['date'] as String,
      value: json['value'] as String,
    );

Map<String, dynamic> _$HabitEntryModelToJson(HabitEntryModel instance) =>
    <String, dynamic>{
      'habitId': instance.habitId,
      'date': instance.date,
      'value': instance.value,
    };
