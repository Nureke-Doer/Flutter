import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/habit.dart';

/// Сопоставление ключей иконок модели с иконками Material.
extension HabitIconX on HabitIcon {
  IconData get iconData => switch (this) {
    HabitIcon.check => Icons.check_circle_outline,
    HabitIcon.water => Icons.water_drop_outlined,
    HabitIcon.run => Icons.directions_run,
    HabitIcon.book => Icons.menu_book_outlined,
    HabitIcon.code => Icons.code,
    HabitIcon.language => Icons.translate,
    HabitIcon.math => Icons.calculate_outlined,
    HabitIcon.meditation => Icons.self_improvement,
    HabitIcon.sleep => Icons.bedtime_outlined,
    HabitIcon.music => Icons.music_note_outlined,
    HabitIcon.science => Icons.science_outlined,
    HabitIcon.art => Icons.palette_outlined,
  };
}

extension HabitTypeX on HabitType {
  String label(AppLocalizations l10n) => switch (this) {
    HabitType.habit => l10n.habitTypeHabit,
    HabitType.study => l10n.habitTypeStudy,
  };

  IconData get iconData => switch (this) {
    HabitType.habit => Icons.repeat,
    HabitType.study => Icons.school_outlined,
  };
}

extension HabitColorX on Habit {
  Color get color => Color(colorValue);
}

/// Палитра цветов для выбора при создании цели.
const List<int> habitPalette = [
  0xFF00897B,
  0xFF1E88E5,
  0xFF8E24AA,
  0xFFE53935,
  0xFFFB8C00,
  0xFF43A047,
  0xFF6D4C41,
  0xFF3949AB,
];

/// Короткое название дня недели (1 — понедельник) для текущей локали.
String weekdayShort(BuildContext context, int weekday) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  // 1 января 2024 года — понедельник.
  final name = DateFormat.E(locale).format(DateTime(2024, 1, weekday));
  return name[0].toUpperCase() + name.substring(1);
}

/// Форматирует минуты от начала суток в строку времени (например, 09:30).
String formatMinutes(BuildContext context, int minutes) {
  final time = TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
  return MaterialLocalizations.of(context).formatTimeOfDay(
    time,
    alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
  );
}
