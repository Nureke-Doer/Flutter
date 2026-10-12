// Шаблон. Настоящий файл создаёт команда `flutterfire configure`
// (см. README → «Неделя 8 → Как подключить свой проект Firebase»).
//
// Пока проект Firebase не подключён, `currentPlatform` бросает
// UnsupportedError — приложение ловит его и работает без облака:
// гостевой режим, данные только на устройстве.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    throw UnsupportedError(
      'Firebase не настроен: выполните `flutterfire configure`.',
    );
  }
}
