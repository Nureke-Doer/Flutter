import 'package:equatable/equatable.dart';

/// Предпочтение темы (доменный слой не зависит от Flutter `ThemeMode`).
enum ThemePreference { system, light, dark }

/// Настройки пользователя.
class AppSettings extends Equatable {
  const AppSettings({
    this.themePreference = ThemePreference.system,
    this.languageCode = 'ru',
    this.gamificationEnabled = false,
  });

  final ThemePreference themePreference;
  final String languageCode;

  /// Модуль «Геймификация». По умолчанию выключен: пока он выключен,
  /// в интерфейсе нет ни одного упоминания метрик.
  final bool gamificationEnabled;

  AppSettings copyWith({
    ThemePreference? themePreference,
    String? languageCode,
    bool? gamificationEnabled,
  }) => AppSettings(
    themePreference: themePreference ?? this.themePreference,
    languageCode: languageCode ?? this.languageCode,
    gamificationEnabled: gamificationEnabled ?? this.gamificationEnabled,
  );

  @override
  List<Object?> get props => [
    themePreference,
    languageCode,
    gamificationEnabled,
  ];
}
