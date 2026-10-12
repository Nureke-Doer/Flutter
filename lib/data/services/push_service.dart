import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../core/firebase/firebase_setup.dart';
import '../../domain/repositories/reminder_scheduler.dart';

/// Обработчик push-сообщений, когда приложение закрыто или свёрнуто.
///
/// Должен быть функцией верхнего уровня: Android запускает его в отдельном
/// изоляте, поэтому Firebase инициализируется заново. Сообщения с блоком
/// `notification` система показывает сама.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await initFirebase();
  debugPrint('FCM (фон): ${message.messageId}');
}

/// Push-уведомления через Firebase Cloud Messaging.
///
/// - запрашивает разрешение, получает токен устройства и сохраняет его в
///   `users/{uid}/devices/{token}` (по нему сервер или консоль Firebase
///   отправляют push именно этому пользователю);
/// - подписывает на тему `daily_summary` (рассылка всем из консоли);
/// - на переднем плане показывает сообщение локальным уведомлением;
/// - нажатие на уведомление открывает экран из `data.route`.
class PushService {
  PushService({
    required FirebaseMessaging messaging,
    required FirebaseFirestore firestore,
    required ReminderScheduler notifications,
  }) : _messaging = messaging,
       _db = firestore,
       _notifications = notifications;

  static const topic = 'daily_summary';

  final FirebaseMessaging _messaging;
  final FirebaseFirestore _db;
  final ReminderScheduler _notifications;
  final token = ValueNotifier<String?>(null);

  Future<void> init({required void Function(String route) onOpen}) async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    final settings = await _messaging.requestPermission();
    debugPrint('FCM permission: ${settings.authorizationStatus}');

    FirebaseMessaging.onMessage.listen((message) {
      final n = message.notification;
      if (n == null) return;
      _notifications.showNow(
        title: n.title ?? '',
        body: n.body ?? '',
        payload: message.data['route'] as String?,
      );
    });
    FirebaseMessaging.onMessageOpenedApp.listen(
      (m) => onOpen(m.data['route'] as String? ?? '/today'),
    );
    final initial = await _messaging.getInitialMessage();
    if (initial != null) onOpen(initial.data['route'] as String? ?? '/today');

    try {
      token.value = await _messaging.getToken();
      _messaging.onTokenRefresh.listen((t) => token.value = t);
      await _messaging.subscribeToTopic(topic);
    } on Object catch (e) {
      debugPrint('FCM token: $e');
    }
  }

  /// Сохраняет токен устройства в профиле пользователя.
  Future<void> registerDevice(String uid) async {
    final t = token.value;
    if (t == null) return;
    await _db.collection('users').doc(uid).collection('devices').doc(t).set({
      'platform': defaultTargetPlatform.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
