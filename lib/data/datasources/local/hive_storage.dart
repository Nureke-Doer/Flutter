import 'package:hive_ce/hive.dart';

/// Имена «коробок» (boxes) Hive. Каждая коробка — отдельный файл
/// с парами ключ → значение. Значения храним JSON-строками,
/// поэтому TypeAdapter-ы не нужны.
abstract final class HiveBoxes {
  /// Цели пользователя: id → JSON цели.
  static const habits = 'habits';

  /// Кэш ответов API: ключ запроса → JSON {savedAt, data}.
  static const apiCache = 'api_cache';

  /// Избранные учебные материалы: id книги → JSON книги.
  static const favorites = 'favorites';

  /// Служебные значения (история поиска, флаги).
  static const meta = 'meta';

  static const all = [habits, apiCache, favorites, meta];
}

/// Открывает все коробки. Вызывается при старте приложения
/// после `Hive.initFlutter()` (или `Hive.init(path)` в тестах).
Future<void> openHiveBoxes() async {
  for (final name in HiveBoxes.all) {
    await Hive.openBox<String>(name);
  }
}
