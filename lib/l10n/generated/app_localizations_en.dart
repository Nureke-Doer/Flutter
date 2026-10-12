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

  @override
  String get detailMarkToday => 'Mark today';

  @override
  String get detailDoneToday => 'Done today';

  @override
  String get deletedMessage => 'Goal deleted';

  @override
  String get undo => 'Undo';

  @override
  String get errorLoading => 'Failed to load data';

  @override
  String get retry => 'Retry';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageEnglish => 'English';

  @override
  String get materialsTitle => 'Study materials';

  @override
  String get materialsSearchHint => 'Search books: topic, author, subject…';

  @override
  String get materialsIntro => 'Find books and textbooks for your goals';

  @override
  String get materialsSuggestions => 'Popular topics';

  @override
  String materialsEmpty(String query) {
    return 'Nothing found for “$query”';
  }

  @override
  String get materialsEmptyHint => 'Try a different query';

  @override
  String get materialsLoadMoreError => 'Failed to load more';

  @override
  String materialsFound(int count) {
    return 'Found: $count';
  }

  @override
  String get bookAuthors => 'Authors';

  @override
  String get bookYear => 'First published';

  @override
  String get bookPages => 'Pages';

  @override
  String get bookEditions => 'Editions';

  @override
  String get bookSubjects => 'Subjects';

  @override
  String get bookUnknownAuthor => 'Unknown author';

  @override
  String get bookOpenLibrary => 'Source: Open Library';

  @override
  String get findMaterials => 'Find materials';

  @override
  String get errorNetwork => 'No internet connection';

  @override
  String get errorTimeout => 'Server is not responding. Try later';

  @override
  String errorServer(String code) {
    return 'Server error ($code)';
  }

  @override
  String get errorParsing => 'Server returned invalid data';

  @override
  String get errorUnknown => 'Something went wrong';

  @override
  String get quoteOfDay => 'Quote of the day';

  @override
  String get materialsTabSearch => 'Search';

  @override
  String get materialsTabSaved => 'Saved';

  @override
  String get savedEmpty => 'Saved books will appear here';

  @override
  String get savedEmptyHint =>
      'Tap the bookmark on a book — it will be available offline';

  @override
  String get addToSaved => 'Save';

  @override
  String get removeFromSaved => 'Remove from saved';

  @override
  String offlineBanner(String date) {
    return 'Offline — showing results saved on $date';
  }

  @override
  String get recentSearches => 'Recent searches';

  @override
  String get clearHistory => 'Clear';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsClearCache => 'Clear cache';

  @override
  String get settingsClearCacheHint => 'Saved API responses and search history';

  @override
  String get cacheCleared => 'Cache cleared';

  @override
  String get settingsOfflineHint =>
      'Goals, settings and saved books are stored on the device and work offline';
}
