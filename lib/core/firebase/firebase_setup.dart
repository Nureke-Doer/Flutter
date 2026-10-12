import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

/// Инициализирует Firebase. Возвращает `false`, если проект не настроен
/// (шаблонный `firebase_options.dart`) или инициализация не удалась —
/// тогда приложение работает офлайн, без аккаунтов и облака.
Future<bool> initFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    return true;
  } on UnsupportedError catch (e) {
    debugPrint('Firebase: ${e.message}');
    return false;
  } on Object catch (e) {
    debugPrint('Firebase init failed: $e');
    return false;
  }
}
