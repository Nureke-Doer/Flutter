import 'package:equatable/equatable.dart';

import '../../core/utils/date_utils.dart';
import 'entry_value.dart';

export 'entry_value.dart';

/// Отметка привычки за конкретный день.
///
/// Записи создаются только для дней, которые пользователь отметил.
/// Пустые дни заранее не создаются: «нет записи» = «пусто».
class HabitEntry extends Equatable {
  HabitEntry({
    required this.habitId,
    required DateTime date,
    required this.value,
  }) : date = dateOnly(date);

  final String habitId;

  /// Дата без времени.
  final DateTime date;
  final EntryValue value;

  /// Ключ записи в хранилище: одна запись на привычку и день.
  String get key => keyFor(habitId, date);

  static String keyFor(String habitId, DateTime day) =>
      '$habitId|${formatDay(day)}';

  @override
  List<Object?> get props => [habitId, date, value];
}
