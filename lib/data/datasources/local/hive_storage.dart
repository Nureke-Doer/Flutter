import 'package:hive_ce/hive.dart';

/// Имена «коробок» (boxes) Hive. Каждая коробка — отдельный файл
/// с парами ключ → значение. Значения храним JSON-строками,
/// поэтому TypeAdapter-ы не нужны.
abstract final class HiveBoxes {
  /// Привычки: id → запись с JSON привычки.
  static const habits = 'habits_v2';

  /// Отметки: `habitId|yyyy-MM-dd` → запись с JSON отметки.
  static const entries = 'entries';

  /// Категории привычек.
  static const categories = 'categories';

  /// Учебные цели.
  static const goals = 'goals';

  /// Метрики геймификации.
  static const metrics = 'metrics';

  /// Связи «привычка → метрика»: `habitId|metricId` → награда и штраф.
  static const metricRules = 'metric_rules';

  /// Кэш ответов API: ключ запроса → JSON {savedAt, data}.
  static const apiCache = 'api_cache';

  /// Избранные учебные материалы: id книги → JSON книги.
  static const favorites = 'favorites';

  /// Служебные значения (история поиска, флаги).
  static const meta = 'meta';

  /// Коробка недель 4–6 (старый формат: отметки внутри привычки).
  /// Открывается только для миграции, см. `local_bootstrap.dart`.
  static const legacyHabits = 'habits';

  static const all = [
    habits,
    entries,
    categories,
    goals,
    metrics,
    metricRules,
    apiCache,
    favorites,
    meta,
  ];
}

/// Открывает все коробки. Вызывается при старте приложения
/// после `Hive.initFlutter()` (или `Hive.init(path)` в тестах).
Future<void> openHiveBoxes() async {
  for (final name in HiveBoxes.all) {
    await Hive.openBox<String>(name);
  }
}

/// Коробка по имени (должна быть уже открыта).
Box<String> hiveBox(String name) => Hive.box<String>(name);
