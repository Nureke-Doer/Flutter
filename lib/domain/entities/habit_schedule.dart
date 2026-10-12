import 'package:equatable/equatable.dart';

/// Вид расписания привычки.
enum ScheduleType {
  /// Каждый день.
  daily,

  /// Только выбранные дни недели.
  weekdays,

  /// N раз в неделю в любые дни.
  timesPerWeek,
}

/// Расписание привычки: каждый день / дни недели / N раз в неделю.
class HabitSchedule extends Equatable {
  const HabitSchedule.daily()
    : type = ScheduleType.daily,
      weekdays = allWeekdays,
      timesPerWeek = 7;

  const HabitSchedule.weekdays(this.weekdays)
    : type = ScheduleType.weekdays,
      timesPerWeek = 7;

  const HabitSchedule.timesPerWeek(this.timesPerWeek)
    : type = ScheduleType.timesPerWeek,
      weekdays = allWeekdays;

  static const Set<int> allWeekdays = {1, 2, 3, 4, 5, 6, 7};

  final ScheduleType type;

  /// Дни недели (1 — понедельник … 7 — воскресенье) для [ScheduleType.weekdays].
  final Set<int> weekdays;

  /// Сколько раз в неделю для [ScheduleType.timesPerWeek] (1–7).
  final int timesPerWeek;

  /// Показывать ли привычку в этот день на экране «Сегодня».
  ///
  /// Привычка «N раз в неделю» показывается каждый день — пользователь
  /// сам выбирает, в какие дни её выполнить.
  bool isScheduledOn(DateTime day) => switch (type) {
    ScheduleType.daily || ScheduleType.timesPerWeek => true,
    ScheduleType.weekdays => weekdays.contains(day.weekday),
  };

  @override
  List<Object?> get props => [type, weekdays, timesPerWeek];
}
