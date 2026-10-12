import 'package:json_annotation/json_annotation.dart';

import '../../core/utils/date_utils.dart';
import '../../domain/entities/study_goal.dart';

part 'study_goal_model.g.dart';

@JsonSerializable()
class StudyGoalModel {
  const StudyGoalModel({
    required this.id,
    required this.title,
    required this.target,
    required this.deadline,
    required this.createdAt,
    this.description = '',
    this.unit = '',
    this.linkedHabitIds = const [],
    this.manualProgress = 0,
    this.archived = false,
    this.bookTitle,
    this.bookCoverId,
  });

  factory StudyGoalModel.fromJson(Map<String, dynamic> json) =>
      _$StudyGoalModelFromJson(json);

  factory StudyGoalModel.fromEntity(StudyGoal g) => StudyGoalModel(
    id: g.id,
    title: g.title,
    description: g.description,
    target: g.target,
    unit: g.unit,
    deadline: formatDay(g.deadline),
    linkedHabitIds: g.linkedHabitIds.toList()..sort(),
    manualProgress: g.manualProgress,
    archived: g.archived,
    bookTitle: g.bookTitle,
    bookCoverId: g.bookCoverId,
    createdAt: formatDay(g.createdAt),
  );

  final String id;
  final String title;
  final String description;
  final double target;
  final String unit;
  final String deadline;
  final List<String> linkedHabitIds;
  final double manualProgress;
  final bool archived;
  final String? bookTitle;
  final int? bookCoverId;
  final String createdAt;

  Map<String, dynamic> toJson() => _$StudyGoalModelToJson(this);

  StudyGoal toEntity() => StudyGoal(
    id: id,
    title: title,
    description: description,
    target: target,
    unit: unit,
    deadline: parseDay(deadline),
    linkedHabitIds: linkedHabitIds.toSet(),
    manualProgress: manualProgress,
    archived: archived,
    bookTitle: bookTitle,
    bookCoverId: bookCoverId,
    createdAt: parseDay(createdAt),
  );
}
