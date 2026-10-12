import 'package:equatable/equatable.dart';

/// Предпочтение темы (доменный слой не зависит от Flutter `ThemeMode`).
enum ThemePreference { system, light, dark }

/// Настройки пользователя.
class AppSettings extends Equatable {
  const AppSettings({
    this.themePreference = ThemePreference.system,
    this.languageCode = 'ru',
  });

  final ThemePreference themePreference;
  final String languageCode;

  @override
  List<Object?> get props => [themePreference, languageCode];
}
