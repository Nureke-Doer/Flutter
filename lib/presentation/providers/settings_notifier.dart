import 'package:flutter/material.dart';

import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

/// Настройки интерфейса: тема и язык.
///
/// Простое состояние без асинхронной логики — поэтому здесь используется
/// Provider (`ChangeNotifier`), а не BLoC. Значения сохраняются
/// в SharedPreferences через [SettingsRepository] и восстанавливаются
/// при следующем запуске.
class SettingsNotifier extends ChangeNotifier {
  SettingsNotifier(this._repository) : _settings = _repository.load();

  final SettingsRepository _repository;
  AppSettings _settings;

  ThemeMode get themeMode => switch (_settings.themePreference) {
    ThemePreference.system => ThemeMode.system,
    ThemePreference.light => ThemeMode.light,
    ThemePreference.dark => ThemeMode.dark,
  };

  Locale get locale => Locale(_settings.languageCode);

  Future<void> setThemeMode(ThemeMode mode) async {
    final preference = switch (mode) {
      ThemeMode.system => ThemePreference.system,
      ThemeMode.light => ThemePreference.light,
      ThemeMode.dark => ThemePreference.dark,
    };
    if (preference == _settings.themePreference) return;
    _settings = AppSettings(
      themePreference: preference,
      languageCode: _settings.languageCode,
    );
    notifyListeners();
    await _repository.saveThemePreference(preference);
  }

  Future<void> setLocale(Locale locale) async {
    if (locale.languageCode == _settings.languageCode) return;
    _settings = AppSettings(
      themePreference: _settings.themePreference,
      languageCode: locale.languageCode,
    );
    notifyListeners();
    await _repository.saveLanguageCode(locale.languageCode);
  }
}
