import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/di/app_services.dart';
import 'core/di/injection.dart';
import 'core/firebase/firebase_setup.dart';
import 'domain/repositories/auth_repository.dart';
import 'presentation/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Hive хранит файлы в папке документов приложения.
  await Hive.initFlutter();
  // Firebase необязателен: без настроенного проекта приложение работает
  // в гостевом режиме (см. README → неделя 8).
  final firebaseReady = await initFirebase();
  await configureDependencies(firebaseReady: firebaseReady);

  final router = createRouter(auth: getIt<AuthRepository>());
  runApp(HabitStudyTrackerApp(router: router));
  unawaited(startAppServices(openRoute: router.go));
}
