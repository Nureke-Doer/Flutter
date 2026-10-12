import 'package:json_annotation/json_annotation.dart';

import '../../core/utils/date_utils.dart';
import '../../domain/entities/habit_entry.dart';

part 'habit_entry_model.g.dart';

/// Отметка за день в хранилище: `{habitId, date: "2026-09-09", value: "done"}`.
@JsonSerializable()
class HabitEntryModel {
  const HabitEntryModel({
    required this.habitId,
    required this.date,
    required this.value,
  });

  factory HabitEntryModel.fromJson(Map<String, dynamic> json) =>
      _$HabitEntryModelFromJson(json);

  factory HabitEntryModel.fromEntity(HabitEntry e) => HabitEntryModel(
    habitId: e.habitId,
    date: formatDay(e.date),
    value: e.value.encode(),
  );

  final String habitId;
  final String date;

  /// Значение в виде строки: `done`, `failed`, `skip`, `n:12.5`.
  final String value;

  Map<String, dynamic> toJson() => _$HabitEntryModelToJson(this);

  /// `null`, если значение не удалось разобрать.
  HabitEntry? toEntity() {
    final v = EntryValue.decode(value);
    if (v == null) return null;
    return HabitEntry(habitId: habitId, date: parseDay(date), value: v);
  }
}
