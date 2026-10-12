// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_goal_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudyGoalModel _$StudyGoalModelFromJson(Map<String, dynamic> json) =>
    StudyGoalModel(
      id: json['id'] as String,
      title: json['title'] as String,
      target: (json['target'] as num).toDouble(),
      deadline: json['deadline'] as String,
      createdAt: json['createdAt'] as String,
      description: json['description'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      linkedHabitIds:
          (json['linkedHabitIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      manualProgress: (json['manualProgress'] as num?)?.toDouble() ?? 0,
      archived: json['archived'] as bool? ?? false,
      bookTitle: json['bookTitle'] as String?,
      bookCoverId: (json['bookCoverId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$StudyGoalModelToJson(StudyGoalModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'target': instance.target,
      'unit': instance.unit,
      'deadline': instance.deadline,
      'linkedHabitIds': instance.linkedHabitIds,
      'manualProgress': instance.manualProgress,
      'archived': instance.archived,
      'bookTitle': instance.bookTitle,
      'bookCoverId': instance.bookCoverId,
      'createdAt': instance.createdAt,
    };
