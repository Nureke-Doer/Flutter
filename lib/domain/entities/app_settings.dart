import 'package:equatable/equatable.dart';

/// Предпочтение темы (доменный слой не зависит от Flutter `ThemeMode`).
enum ThemePreference { system, light, dark }

/// Настройки пользователя.
class AppSettings extends Equatable {
  const AppSettings({
    this.themePreference = ThemePreference.system,
    this.languageCode = 'ru',
    this.gamificationEnabled = false,
    this.dailySummaryMinutes,
  });

  final ThemePreference themePreference;
  final String languageCode;

  /// Модуль «Геймификация». По умолчанию выключен: пока он выключен,
  /// в интерфейсе нет ни одного упоминания метрик.
  final bool gamificationEnabled;

  /// Время ежедневной сводки (минуты от начала суток), `null` — выключена.
  final int? dailySummaryMinutes;

  AppSettings copyWith({
    ThemePreference? themePreference,
    String? languageCode,
    bool? gamificationEnabled,
    int? Function()? dailySummaryMinutes,
  }) => AppSettings(
    themePreference: themePreference ?? this.themePreference,
    languageCode: languageCode ?? this.languageCode,
    gamificationEnabled: gamificationEnabled ?? this.gamificationEnabled,
    dailySummaryMinutes: dailySummaryMinutes != null
        ? dailySummaryMinutes()
        : this.dailySummaryMinutes,
  );

  @override
  List<Object?> get props => [
    themePreference,
    languageCode,
    gamificationEnabled,
    dailySummaryMinutes,
  ];
}
