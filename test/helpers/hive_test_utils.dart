import 'dart:io';

import 'package:habit_study_tracker/data/datasources/local/hive_storage.dart';
import 'package:hive_ce/hive.dart';

/// Инициализирует Hive во временной папке и открывает все коробки.
Future<void> setUpTestHive() async {
  final dir = await Directory.systemTemp.createTemp('hive_test_');
  Hive.init(dir.path);
  await openHiveBoxes();
}

/// Удаляет все коробки с диска и закрывает Hive.
Future<void> tearDownTestHive() => Hive.deleteFromDisk();
