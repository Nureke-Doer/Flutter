import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/habit.dart';

part 'habit_model.g.dart';

/// Модель цели для локального хранения (Hive) в виде JSON.
///
/// Даты выполнения хранятся строками `yyyy-MM-dd` — так они не зависят
/// от часового пояса и легко читаются при отладке.
@JsonSerializable()
class HabitModel {
  const HabitModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.icon,
    required this.colorValue,
    required this.weekdays,
    required this.completedDays,
    required this.createdAt,
    this.reminderMinutes,
    this.targetMinutes,
  });

  factory HabitModel.fromJson(Map<String, dynamic> json) =>
      _$HabitModelFromJson(json);

  factory HabitModel.fromEntity(Habit h) => HabitModel(
    id: h.id,
    title: h.title,
    description: h.description,
    type: h.type,
    icon: h.icon,
    colorValue: h.colorValue,
    weekdays: h.weekdays.toList()..sort(),
    reminderMinutes: h.reminderMinutes,
    targetMinutes: h.targetMinutes,
    completedDays: (h.completedDays.map(_formatDay).toList()..sort()),
    createdAt: h.createdAt.toIso8601String(),
  );

  final String id;
  final String title;
  final String description;
  @JsonKey(unknownEnumValue: HabitType.habit)
  final HabitType type;
  @JsonKey(unknownEnumValue: HabitIcon.check)
  final HabitIcon icon;
  final int colorValue;
  final List<int> weekdays;
  final int? reminderMinutes;
  final int? targetMinutes;
  final List<String> completedDays;
  final String createdAt;

  Map<String, dynamic> toJson() => _$HabitModelToJson(this);

  Habit toEntity() => Habit(
    id: id,
    title: title,
    description: description,
    type: type,
    icon: icon,
    colorValue: colorValue,
    weekdays: weekdays.toSet(),
    reminderMinutes: reminderMinutes,
    targetMinutes: targetMinutes,
    completedDays: completedDays.map(DateTime.parse).toSet(),
    createdAt: DateTime.parse(createdAt),
  );

  static String _formatDay(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
