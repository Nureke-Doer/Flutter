import '../services/reminder_planner.dart';

/// Планировщик локальных уведомлений (реализация — в слое data).
abstract interface class ReminderScheduler {
  /// Запросить разрешение на уведомления (Android 13+, iOS).
  Future<bool> requestPermission();

  /// Заменяет все запланированные напоминания на [reminders].
  Future<void> replaceAll(List<PlannedReminder> reminders);

  /// Показать уведомление сразу (проверка, сообщение FCM на переднем плане).
  Future<void> showNow({
    required String title,
    required String body,
    String? payload,
  });
}

/// Заглушка для web и тестов: уведомления не планируются.
class NoopReminderScheduler implements ReminderScheduler {
  const NoopReminderScheduler();

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> replaceAll(List<PlannedReminder> reminders) async {}

  @override
  Future<void> showNow({
    required String title,
    required String body,
    String? payload,
  }) async {}
}
