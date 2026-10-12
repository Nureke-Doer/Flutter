import 'package:flutter_test/flutter_test.dart';
import 'package:habit_study_tracker/data/services/local_notifications_scheduler.dart';
import 'package:habit_study_tracker/domain/entities/habit.dart';
import 'package:habit_study_tracker/domain/services/reminder_planner.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

void main() {
  tz_data.initializeTimeZones();
  const texts = ReminderTexts(
    habitBody: 'Пора!',
    summaryTitle: 'Итоги дня',
    summaryBody: 'Отметьте привычки',
  );
  final created = DateTime(2026, 9, 1);

  test('ежедневная, по дням недели, архивная и без времени', () {
    final plan = planReminders(
      [
        Habit(id: 'a', title: 'Вода', createdAt: created, reminderMinutes: 540),
        Habit(
          id: 'b',
          title: 'Зал',
          createdAt: created,
          reminderMinutes: 1080,
          schedule: const HabitSchedule.weekdays({1, 3, 5}),
        ),
        Habit(
          id: 'c',
          title: 'Старая',
          createdAt: created,
          reminderMinutes: 600,
          archived: true,
        ),
        Habit(id: 'd', title: 'Без времени', createdAt: created),
      ],
      texts: texts,
      summaryMinutes: 21 * 60,
    );

    expect(plan.where((r) => r.title == 'Вода').single.weekday, isNull);
    expect(plan.where((r) => r.title == 'Зал').map((r) => r.weekday), [
      1,
      3,
      5,
    ]);
    expect(plan.any((r) => r.title == 'Старая'), isFalse);
    expect(plan.any((r) => r.title == 'Без времени'), isFalse);
    final summary = plan.singleWhere((r) => r.title == 'Итоги дня');
    expect(summary.minutes, 1260);
    expect(summary.payload, '/today');
    expect(plan.first.payload, '/habit/a');
    // Номера уведомлений уникальны.
    expect(plan.map((r) => r.id).toSet().length, plan.length);
  });

  test('без сводки — только напоминания привычек', () {
    expect(planReminders(const [], texts: texts), isEmpty);
  });

  group('ближайшее срабатывание', () {
    final almaty = tz.getLocation('Asia/Almaty');
    // Среда, 9 сентября 2026, 10:00.
    final now = tz.TZDateTime(almaty, 2026, 9, 9, 10);

    PlannedReminder at(int minutes, {int? weekday}) => PlannedReminder(
      id: 1,
      minutes: minutes,
      weekday: weekday,
      title: 't',
      body: 'b',
    );

    test('позже сегодня — сегодня', () {
      final next = LocalNotificationsScheduler.nextInstance(now, at(18 * 60));
      expect(next, tz.TZDateTime(almaty, 2026, 9, 9, 18));
    });

    test('время уже прошло — завтра', () {
      final next = LocalNotificationsScheduler.nextInstance(now, at(9 * 60));
      expect(next, tz.TZDateTime(almaty, 2026, 9, 10, 9));
    });

    test('по дню недели — ближайший понедельник', () {
      final next = LocalNotificationsScheduler.nextInstance(
        now,
        at(7 * 60, weekday: 1),
      );
      expect(next, tz.TZDateTime(almaty, 2026, 9, 14, 7));
    });
  });
}
