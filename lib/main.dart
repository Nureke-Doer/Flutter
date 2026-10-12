import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Hive хранит файлы в папке документов приложения.
  await Hive.initFlutter();
  await configureDependencies();
  runApp(const HabitStudyTrackerApp());
}
