import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

/// Настройки в SharedPreferences — простое хранилище «ключ → значение»
/// для небольших данных (тема, язык).
class SharedPrefsSettingsRepository implements SettingsRepository {
  SharedPrefsSettingsRepository(this._prefs, {this.defaultLanguageCode = 'ru'});

  static const themeKey = 'settings.theme';
  static const languageKey = 'settings.language';
  static const supportedLanguages = {'ru', 'en'};

  final SharedPreferences _prefs;

  /// Язык по умолчанию (например, язык устройства), если пользователь
  /// ещё ничего не выбирал.
  final String defaultLanguageCode;

  @override
  AppSettings load() {
    final theme = ThemePreference.values
        .asNameMap()[_prefs.getString(themeKey)];
    final language = _prefs.getString(languageKey);
    return AppSettings(
      themePreference: theme ?? ThemePreference.system,
      languageCode: supportedLanguages.contains(language)
          ? language!
          : (supportedLanguages.contains(defaultLanguageCode)
                ? defaultLanguageCode
                : 'ru'),
    );
  }

  @override
  Future<void> saveThemePreference(ThemePreference preference) =>
      _prefs.setString(themeKey, preference.name);

  @override
  Future<void> saveLanguageCode(String languageCode) =>
      _prefs.setString(languageKey, languageCode);
}
