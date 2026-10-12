import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/habit.dart';

part 'habit_model.g.dart';

/// Модель привычки для хранения (Hive, Firestore) в виде JSON.
///
/// Отделена от доменной сущности [Habit]: формат хранения можно менять,
/// не трогая бизнес-логику. Код `fromJson`/`toJson` генерируется
/// пакетом json_serializable (`habit_model.g.dart`).
@JsonSerializable()
class HabitModel {
  const HabitModel({
    required this.id,
    required this.title,
    required this.createdAt,
    this.description = '',
    this.categoryId,
    this.kind = HabitKind.positive,
    this.icon = HabitIcon.check,
    this.colorValue = 0xFF00897B,
    this.unit,
    this.target,
    this.scheduleType = ScheduleType.daily,
    this.weekdays = const [1, 2, 3, 4, 5, 6, 7],
    this.timesPerWeek = 7,
    this.reminderMinutes,
    this.archived = false,
    this.placeId,
  });

  factory HabitModel.fromJson(Map<String, dynamic> json) =>
      _$HabitModelFromJson(json);

  factory HabitModel.fromEntity(Habit h) => HabitModel(
    id: h.id,
    title: h.title,
    description: h.description,
    categoryId: h.categoryId,
    kind: h.kind,
    icon: h.icon,
    colorValue: h.colorValue,
    unit: h.unit,
    target: h.target,
    scheduleType: h.schedule.type,
    weekdays: h.schedule.weekdays.toList()..sort(),
    timesPerWeek: h.schedule.timesPerWeek,
    reminderMinutes: h.reminderMinutes,
    archived: h.archived,
    placeId: h.placeId,
    createdAt: h.createdAt.toIso8601String(),
  );

  final String id;
  final String title;
  final String description;
  final String? categoryId;
  // unknownEnumValue: если в данных окажется неизвестное значение
  // (например, из более новой версии приложения), не падаем.
  @JsonKey(unknownEnumValue: HabitKind.positive)
  final HabitKind kind;
  @JsonKey(unknownEnumValue: HabitIcon.check)
  final HabitIcon icon;
  final int colorValue;
  final String? unit;
  final double? target;
  @JsonKey(unknownEnumValue: ScheduleType.daily)
  final ScheduleType scheduleType;
  final List<int> weekdays;
  final int timesPerWeek;
  final int? reminderMinutes;
  final bool archived;
  final String? placeId;
  final String createdAt;

  Map<String, dynamic> toJson() => _$HabitModelToJson(this);

  Habit toEntity() => Habit(
    id: id,
    title: title,
    description: description,
    categoryId: categoryId,
    kind: kind,
    icon: icon,
    colorValue: colorValue,
    unit: unit,
    target: target,
    schedule: switch (scheduleType) {
      ScheduleType.daily => const HabitSchedule.daily(),
      ScheduleType.weekdays => HabitSchedule.weekdays(weekdays.toSet()),
      ScheduleType.timesPerWeek => HabitSchedule.timesPerWeek(timesPerWeek),
    },
    reminderMinutes: reminderMinutes,
    archived: archived,
    placeId: placeId,
    createdAt: DateTime.parse(createdAt),
  );
}
