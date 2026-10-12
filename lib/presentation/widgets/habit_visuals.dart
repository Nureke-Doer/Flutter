import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_entry.dart';
import '../../l10n/generated/app_localizations.dart';

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
    HabitIcon.gym => Icons.fitness_center,
    HabitIcon.walk => Icons.directions_walk,
    HabitIcon.food => Icons.restaurant_outlined,
    HabitIcon.noSmoking => Icons.smoke_free,
    HabitIcon.phone => Icons.phonelink_erase_outlined,
    HabitIcon.money => Icons.savings_outlined,
  };
}

extension HabitKindX on HabitKind {
  String label(AppLocalizations l10n) => switch (this) {
    HabitKind.positive => l10n.kindPositive,
    HabitKind.quit => l10n.kindQuit,
    HabitKind.numeric => l10n.kindNumeric,
  };

  String hint(AppLocalizations l10n) => switch (this) {
    HabitKind.positive => l10n.kindPositiveHint,
    HabitKind.quit => l10n.kindQuitHint,
    HabitKind.numeric => l10n.kindNumericHint,
  };

  IconData get iconData => switch (this) {
    HabitKind.positive => Icons.check_circle_outline,
    HabitKind.quit => Icons.block,
    HabitKind.numeric => Icons.pin_outlined,
  };
}

extension HabitColorX on Habit {
  Color get color => Color(colorValue);
}

/// Цвета значений отметки (одинаковые во всём приложении).
abstract final class EntryColors {
  static const failed = Color(0xFFE53935);
}

/// Подписи значений с учётом типа привычки:
/// для «отказа от вредного» ✔ — «удержался», ✘ — «сорвался».
extension EntryValueLabels on Habit {
  String doneLabel(AppLocalizations l10n) =>
      kind == HabitKind.quit ? l10n.entryHeld : l10n.entryDone;

  String failedLabel(AppLocalizations l10n) =>
      kind == HabitKind.quit ? l10n.entryRelapsed : l10n.entryFailed;

  /// Короткое описание значения за день («✔», «✘», «0», «25 мин»).
  String valueLabel(EntryValue? value, AppLocalizations l10n) =>
      switch (value) {
        null => l10n.entryEmpty,
        EntryDone() => doneLabel(l10n),
        EntryFailed() => failedLabel(l10n),
        EntrySkipped() => l10n.entrySkipped,
        EntryAmount(:final amount) => formatAmount(amount, unit),
      };

  /// Расписание текстом.
  String scheduleLabel(BuildContext context, AppLocalizations l10n) =>
      switch (schedule.type) {
        ScheduleType.daily => l10n.detailEveryDay,
        ScheduleType.weekdays =>
          (schedule.weekdays.toList()..sort())
              .map((d) => weekdayShort(context, d))
              .join(', '),
        ScheduleType.timesPerWeek => l10n.timesPerWeek(schedule.timesPerWeek),
      };
}

/// Число без лишних нулей: 8 → «8», 2.5 → «2,5» (с единицей, если есть).
String formatAmount(double value, [String? unit]) {
  final number = NumberFormat.decimalPattern().format(
    value == value.roundToDouble() ? value.toInt() : value,
  );
  return unit == null || unit.isEmpty ? number : '$number $unit';
}

/// Палитра цветов для выбора при создании привычки.
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
