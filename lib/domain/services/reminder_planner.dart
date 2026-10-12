import 'package:equatable/equatable.dart';

import '../entities/habit.dart';

/// Одно повторяющееся напоминание.
class PlannedReminder extends Equatable {
  const PlannedReminder({
    required this.id,
    required this.minutes,
    required this.title,
    required this.body,
    this.weekday,
    this.payload,
  });

  /// Уникальный номер уведомления (нужен системе).
  final int id;

  /// Время в минутах от начала суток.
  final int minutes;

  /// День недели (1 — понедельник) или `null` — каждый день.
  final int? weekday;
  final String title;
  final String body;

  /// Куда перейти при нажатии (адрес GoRouter, например `/habit/a`).
  final String? payload;

  @override
  List<Object?> get props => [id, minutes, weekday, title, body, payload];
}

/// Тексты уведомлений (передаются из UI на языке пользователя).
class ReminderTexts {
  const ReminderTexts({
    required this.habitBody,
    required this.summaryTitle,
    required this.summaryBody,
  });

  final String habitBody;
  final String summaryTitle;
  final String summaryBody;
}

/// Составляет расписание локальных напоминаний.
///
/// - привычка с временем напоминания «каждый день» или «N раз в неделю» —
///   одно ежедневное уведомление;
/// - «дни недели» — отдельное уведомление на каждый выбранный день;
/// - архивные привычки и привычки без времени — без напоминаний;
/// - ежедневная сводка — если включена в настройках.
///
/// Чистая функция без плагинов — проверяется unit-тестами.
List<PlannedReminder> planReminders(
  List<Habit> habits, {
  required ReminderTexts texts,
  int? summaryMinutes,
}) {
  final result = <PlannedReminder>[];
  var nextId = 1;
  final sorted = [...habits]..sort((a, b) => a.id.compareTo(b.id));
  for (final habit in sorted) {
    final minutes = habit.reminderMinutes;
    if (habit.archived || minutes == null) continue;
    final weekdays = habit.schedule.type == ScheduleType.weekdays
        ? (habit.schedule.weekdays.toList()..sort())
        : const <int?>[null];
    for (final weekday in weekdays) {
      result.add(
        PlannedReminder(
          id: nextId++,
          minutes: minutes,
          weekday: weekday,
          title: habit.title,
          body: texts.habitBody,
          payload: '/habit/${habit.id}',
        ),
      );
    }
  }
  if (summaryMinutes != null) {
    result.add(
      PlannedReminder(
        id: 0,
        minutes: summaryMinutes,
        title: texts.summaryTitle,
        body: texts.summaryBody,
        payload: '/today',
      ),
    );
  }
  return result;
}
