// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Habit & Study Tracker';

  @override
  String get navToday => 'Today';

  @override
  String get navStatistics => 'Statistics';

  @override
  String get navMaterials => 'Materials';

  @override
  String get navSettings => 'Settings';

  @override
  String get todayTitle => 'Today';

  @override
  String todayProgress(int done, int total) {
    return '$done of $total done';
  }

  @override
  String get todayAllDone => 'All goals for today are done! 🎉';

  @override
  String get todayKeepGoing => 'Keep going — you\'re on the right track!';

  @override
  String get todayEmpty => 'Nothing planned for today';

  @override
  String get todayEmptyHint =>
      'Tap “Add” to create your first habit or study goal';

  @override
  String get sectionHabits => 'Habits';

  @override
  String get sectionStudy => 'Study';

  @override
  String get addHabit => 'Add';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '$count day',
      zero: 'no streak',
    );
    return '$_temp0';
  }

  @override
  String minutesShort(int count) {
    return '$count min';
  }

  @override
  String get habitTypeHabit => 'Habit';

  @override
  String get habitTypeStudy => 'Study';

  @override
  String get detailCurrentStreak => 'Current streak';

  @override
  String get detailBestStreak => 'Best streak';

  @override
  String get detailCompletion => 'Last 30 days';

  @override
  String get detailCalendar => 'Completion calendar';

  @override
  String get detailSchedule => 'Schedule';

  @override
  String get detailReminder => 'Reminder';

  @override
  String get detailNoReminder => 'No reminder';

  @override
  String get detailEveryDay => 'Every day';

  @override
  String get detailDescription => 'Description';

  @override
  String get detailTarget => 'Daily target';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String deleteConfirmTitle(String title) {
    return 'Delete “$title”?';
  }

  @override
  String get deleteConfirmBody => 'Completion history will be deleted too.';

  @override
  String get editNewTitle => 'New goal';

  @override
  String get editEditTitle => 'Edit goal';

  @override
  String get editFieldTitle => 'Title';

  @override
  String get editFieldTitleHint => 'For example: 30 minutes of English';

  @override
  String get editFieldTitleError => 'Enter a title';

  @override
  String get editFieldDescription => 'Description (optional)';

  @override
  String get editType => 'Type';

  @override
  String get editIcon => 'Icon';

  @override
  String get editColor => 'Color';

  @override
  String get editDays => 'Days of week';

  @override
  String get editDaysError => 'Select at least one day';

  @override
  String editTargetMinutes(int count) {
    return 'Minutes per day: $count';
  }

  @override
  String get editReminder => 'Reminder';

  @override
  String get editReminderOff => 'Off';

  @override
  String get save => 'Save';

  @override
  String get savedMessage => 'Saved';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get statsWeekRate => 'Completion, last 7 days';

  @override
  String get statsCompletedTotal => 'Total check-ins';

  @override
  String get statsActiveHabits => 'Active goals';

  @override
  String get statsLast7Days => 'Last 7 days';

  @override
  String get statsTopStreaks => 'Top streaks';

  @override
  String get statsEmpty => 'Add goals to see statistics';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsAbout => 'About';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }
}
