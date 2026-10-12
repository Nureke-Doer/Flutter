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
  String get todayTitle => 'Today';

  @override
  String todayProgress(int done, int total) {
    return '$done of $total done';
  }

  @override
  String get todayAllDone => 'All habits for today are done! 🎉';

  @override
  String get todayKeepGoing => 'Keep going — you\'re on the right track!';

  @override
  String get todayEmpty => 'Nothing planned for today';

  @override
  String get todayEmptyHint => 'Tap “Add” to create your first habit';

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
  String get detailCurrentStreak => 'Current streak';

  @override
  String get detailBestStreak => 'Best streak';

  @override
  String get detailCompletion => 'Last 30 days';

  @override
  String get detailCalendar => 'Calendar (tap a day to change it)';

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
  String get deleteConfirmBody => 'Its history will be deleted too.';

  @override
  String get editNewTitle => 'New habit';

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
  String get statsCompletedTotal => 'Days done';

  @override
  String get statsActiveHabits => 'Active habits';

  @override
  String get statsLast7Days => 'Last 7 days';

  @override
  String get statsTopStreaks => 'Top streaks';

  @override
  String get statsEmpty => 'Add habits to see statistics';

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
  String get deletedMessage => 'Habit deleted';

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

  @override
  String get archive => 'Archive';

  @override
  String get unarchive => 'Restore from archive';

  @override
  String get archived => 'Habit archived — history is kept';

  @override
  String get unarchived => 'Habit restored from archive';

  @override
  String get archivedBadge => 'Archived';

  @override
  String get detailByMonth => 'By month';

  @override
  String get detailFailures => 'Missed';

  @override
  String get detailRelapses => 'Relapses';

  @override
  String get detailHeatmap => 'Heatmap (20 weeks)';

  @override
  String get detailNoTarget => 'No target — any number > 0 counts';

  @override
  String detailSum(String unit) {
    return 'Total $unit';
  }

  @override
  String get detailTotalDone => 'Days done';

  @override
  String get editCategory => 'Category';

  @override
  String get editSchedule => 'Schedule';

  @override
  String get editTarget => 'Daily target';

  @override
  String get editTargetError => 'Enter a number greater than 0';

  @override
  String get editUnit => 'Unit';

  @override
  String get editUnitHint => 'min, pages, reps';

  @override
  String get entryAmountLabel => 'Amount done';

  @override
  String get entryClear => 'Clear';

  @override
  String get entryDone => 'Done';

  @override
  String get entryFailed => 'Not done';

  @override
  String get entryHeld => 'Held on';

  @override
  String get entryRelapsed => 'Relapsed';

  @override
  String get entrySkipped => 'Skip (0)';

  @override
  String get entryEmpty => 'not marked';

  @override
  String get entryMoreValues => 'More values';

  @override
  String get entrySkipHint =>
      '“Skip” and an empty day neither break nor extend the streak. Only ✘ breaks it.';

  @override
  String entryTargetHint(String target) {
    return 'Target: $target';
  }

  @override
  String get kindPositive => 'Action';

  @override
  String get kindQuit => 'Quit';

  @override
  String get kindNumeric => 'Number';

  @override
  String get kindPositiveHint => 'Good action: ✔ — done, ✘ — not done.';

  @override
  String get kindQuitHint => 'Quitting a bad habit: ✔ — held on, ✘ — relapsed.';

  @override
  String get kindNumericHint =>
      'Numeric: reps, minutes, pages. Any number above 0 counts as done.';

  @override
  String get monthColumn => 'Month';

  @override
  String get sumColumn => 'Total';

  @override
  String get noCategory => 'No category';

  @override
  String get scheduleDaily => 'Every day';

  @override
  String get scheduleWeekdays => 'Weekdays';

  @override
  String get scheduleTimesPerWeek => 'N per week';

  @override
  String timesPerWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times a week',
      one: 'once a week',
    );
    return '$_temp0';
  }

  @override
  String weekProgress(int done, int total) {
    return '$done of $total this week';
  }

  @override
  String get authEmail => 'Email';

  @override
  String get authEnterEmail => 'Enter your email to reset the password';

  @override
  String get authErrorCancelled => 'Sign-in cancelled';

  @override
  String get authErrorEmailInUse => 'This email is already registered';

  @override
  String get authErrorInvalidEmail => 'Invalid email';

  @override
  String get authErrorTooManyRequests => 'Too many attempts. Try again later';

  @override
  String get authErrorUnavailable =>
      'Account sign-in is unavailable: Firebase is not configured';

  @override
  String get authErrorWeakPassword => 'Password must be at least 6 characters';

  @override
  String get authErrorWrongCredentials => 'Wrong email or password';

  @override
  String get authFirebaseNotConfigured =>
      'Email and Google sign-in will be available once Firebase is connected. For now you can use the app without an account.';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authGoogle => 'Sign in with Google';

  @override
  String get authGuest => 'Continue without an account';

  @override
  String get authGuestHint => 'Data is stored only on this device';

  @override
  String get authGuestName => 'Guest';

  @override
  String get authLeaveGuest => 'Leave guest mode';

  @override
  String get authName => 'Name';

  @override
  String get authOr => 'or';

  @override
  String get authPassword => 'Password';

  @override
  String get authRegister => 'Sign up';

  @override
  String get authResetSent => 'Password reset email sent';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authSignOut => 'Sign out';

  @override
  String get authSignOutBody => 'Your habits stay on this device.';

  @override
  String get authSignOutConfirm => 'Sign out?';

  @override
  String get authSubtitle => 'Habits and study goals in one place';

  @override
  String get categoriesEmpty => 'No categories yet';

  @override
  String get categoriesHint => 'Drag a category by its handle to reorder';

  @override
  String get categoriesTitle => 'Categories';

  @override
  String get categoryAdd => 'New category';

  @override
  String get categoryDeleteBody =>
      'Habits won\'t be deleted — they move to “No category”.';

  @override
  String get goalAdd => 'New goal';

  @override
  String get goalAddProgress => 'Add progress manually';

  @override
  String get goalBook => 'Book';

  @override
  String get goalBookHint =>
      'Save a book in Study materials to link it to a goal';

  @override
  String get goalCompleted => 'Goal reached! 🎉';

  @override
  String goalDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days left',
      one: '$count day left',
      zero: 'due today',
    );
    return '$_temp0';
  }

  @override
  String get goalDaysLeftLabel => 'Days left';

  @override
  String goalDeadline(String date) {
    return 'by $date';
  }

  @override
  String get goalDeadlineLabel => 'Deadline';

  @override
  String get goalEdit => 'Edit goal';

  @override
  String get goalLinkedHabits => 'Linked habits';

  @override
  String get goalLinkedHint =>
      'Progress is automatic: numeric habits add their amounts, others add 1 per ✔.';

  @override
  String get goalManualProgress => 'Added manually';

  @override
  String get goalNew => 'New study goal';

  @override
  String get goalNoBook => 'No book';

  @override
  String get goalNoLinkedHabits => 'None — progress is manual only';

  @override
  String get goalOverdue => 'Deadline passed';

  @override
  String goalPerDay(String amount) {
    return '$amount a day needed';
  }

  @override
  String goalRemaining(String unit) {
    return 'Remaining $unit';
  }

  @override
  String get goalTarget => 'Target';

  @override
  String get goalTitleHint => 'E.g. Read 300 pages';

  @override
  String get goalsEmpty => 'No study goals yet';

  @override
  String get goalsEmptyHint =>
      'Create a goal with a deadline and link habits to it';

  @override
  String get goalsTitle => 'Study goals';

  @override
  String habitsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count habits',
      one: '$count habit',
      zero: 'no habits',
    );
    return '$_temp0';
  }

  @override
  String get habitsEmpty => 'No habits yet';

  @override
  String get navGoals => 'Goals';

  @override
  String get navHabits => 'Habits';

  @override
  String get navProfile => 'Profile';

  @override
  String get notFound => 'Page not found';

  @override
  String get selectHabitHint => 'Select a habit on the left';

  @override
  String get settingsGamification => 'Enable gamification';

  @override
  String get settingsGamificationHint =>
      'Your own metrics (e.g. Power and Money) that grow with completed habits';

  @override
  String showArchived(int count) {
    return 'Archive ($count)';
  }
}
