import '../entities/app_settings.dart';

/// Хранилище настроек (реализация — SharedPreferences).
abstract interface class SettingsRepository {
  /// Читает сохранённые настройки (или значения по умолчанию).
  AppSettings load();

  Future<void> saveThemePreference(ThemePreference preference);

  Future<void> saveLanguageCode(String languageCode);

  Future<void> saveGamificationEnabled(bool enabled);

  /// `null` — выключить ежедневную сводку.
  Future<void> saveDailySummaryMinutes(int? minutes);
}
