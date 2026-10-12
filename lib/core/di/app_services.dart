import 'dart:async';

import '../../data/services/local_notifications_scheduler.dart';
import '../../data/services/push_service.dart';
import '../../data/sync/sync_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/reminder_scheduler.dart';
import '../../presentation/services/reminders_controller.dart';
import 'injection.dart';

/// Запускает сервисы, которые работают в фоне всё время жизни приложения:
/// локальные напоминания, синхронизацию с Firestore и push (FCM).
///
/// [openRoute] — переход на экран при нажатии на уведомление
/// (например, `/habit/water`).
Future<void> startAppServices({
  required void Function(String route) openRoute,
}) async {
  final auth = getIt<AuthRepository>();

  final scheduler = getIt<ReminderScheduler>();
  if (scheduler is LocalNotificationsScheduler) {
    await scheduler.init(onTap: openRoute);
  }
  getIt<RemindersController>().start();

  // Синхронизация включается при входе в аккаунт и выключается при выходе.
  if (getIt.isRegistered<SyncService>()) {
    getIt<SyncService>().bindTo(auth.authStateChanges());
  }

  if (getIt.isRegistered<PushService>()) {
    final push = getIt<PushService>();
    await push.init(onOpen: openRoute);
    auth.authStateChanges().listen((user) {
      if (user != null && !user.isGuest) {
        unawaited(push.registerDevice(user.uid));
      }
    });
  }
}
