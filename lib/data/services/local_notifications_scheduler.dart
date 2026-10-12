import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/repositories/reminder_scheduler.dart';
import '../../domain/services/reminder_planner.dart';

/// Локальные уведомления (flutter_local_notifications) — работают без
/// интернета и без сервера: расписание хранит сама система.
class LocalNotificationsScheduler implements ReminderScheduler {
  LocalNotificationsScheduler({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  static const _channel = AndroidNotificationDetails(
    'reminders',
    'Напоминания о привычках',
    channelDescription: 'Ежедневные напоминания и сводка',
    importance: Importance.high,
    priority: Priority.high,
  );
  static const _details = NotificationDetails(
    android: _channel,
    iOS: DarwinNotificationDetails(),
  );

  /// Инициализация: часовой пояс устройства и обработчик нажатия.
  /// [onTap] получает `payload` — адрес экрана, который нужно открыть.
  Future<void> init({void Function(String payload)? onTap}) async {
    tz_data.initializeTimeZones();
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } on Object catch (e) {
      debugPrint('Timezone: $e — используется UTC');
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && onTap != null) onTap(payload);
      },
    );
    // Приложение запущено нажатием на уведомление.
    final launch = await _plugin.getNotificationAppLaunchDetails();
    final payload = launch?.notificationResponse?.payload;
    if ((launch?.didNotificationLaunchApp ?? false) && payload != null) {
      onTap?.call(payload);
    }
  }

  @override
  Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    return await ios?.requestPermissions(alert: true, sound: true) ?? false;
  }

  @override
  Future<void> replaceAll(List<PlannedReminder> reminders) async {
    await _plugin.cancelAll();
    for (final r in reminders) {
      await _plugin.zonedSchedule(
        id: r.id,
        title: r.title,
        body: r.body,
        payload: r.payload,
        scheduledDate: nextInstance(tz.TZDateTime.now(tz.local), r),
        notificationDetails: _details,
        // Неточное время (± несколько минут) не требует разрешения
        // SCHEDULE_EXACT_ALARM и бережёт батарею.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: r.weekday == null
            ? DateTimeComponents.time
            : DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  /// Ближайший момент срабатывания напоминания после [now].
  @visibleForTesting
  static tz.TZDateTime nextInstance(tz.TZDateTime now, PlannedReminder r) {
    var date = tz.TZDateTime(
      now.location,
      now.year,
      now.month,
      now.day,
      r.minutes ~/ 60,
      r.minutes % 60,
    );
    while (!date.isAfter(now) ||
        (r.weekday != null && date.weekday != r.weekday)) {
      date = tz.TZDateTime(
        now.location,
        date.year,
        date.month,
        date.day + 1,
        date.hour,
        date.minute,
      );
    }
    return date;
  }

  @override
  Future<void> showNow({
    required String title,
    required String body,
    String? payload,
  }) => _plugin.show(
    id: 999999,
    title: title,
    body: body,
    payload: payload,
    notificationDetails: _details,
  );
}
