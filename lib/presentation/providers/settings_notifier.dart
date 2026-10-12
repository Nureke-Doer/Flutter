import 'package:flutter/material.dart';

/// Настройки интерфейса: тема и язык.
///
/// Простое состояние без асинхронной логики — поэтому здесь используется
/// Provider (`ChangeNotifier`), а не BLoC.
/// Неделя 4: значения хранятся в памяти; на неделе 6 — в SharedPreferences.
class SettingsNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('ru');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  void setThemeMode(ThemeMode mode) {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
  }

  void setLocale(Locale locale) {
    if (locale == _locale) return;
    _locale = locale;
    notifyListeners();
  }
}
