import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ru, this message translates to:
  /// **'Habit & Study Tracker'**
  String get appTitle;

  /// No description provided for @navToday.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get navToday;

  /// No description provided for @navStatistics.
  ///
  /// In ru, this message translates to:
  /// **'Статистика'**
  String get navStatistics;

  /// No description provided for @navMaterials.
  ///
  /// In ru, this message translates to:
  /// **'Материалы'**
  String get navMaterials;

  /// No description provided for @navSettings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get navSettings;

  /// No description provided for @todayTitle.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get todayTitle;

  /// No description provided for @todayProgress.
  ///
  /// In ru, this message translates to:
  /// **'Выполнено {done} из {total}'**
  String todayProgress(int done, int total);

  /// No description provided for @todayAllDone.
  ///
  /// In ru, this message translates to:
  /// **'Все цели на сегодня выполнены! 🎉'**
  String get todayAllDone;

  /// No description provided for @todayKeepGoing.
  ///
  /// In ru, this message translates to:
  /// **'Продолжай — ты на верном пути!'**
  String get todayKeepGoing;

  /// No description provided for @todayEmpty.
  ///
  /// In ru, this message translates to:
  /// **'На сегодня ничего не запланировано'**
  String get todayEmpty;

  /// No description provided for @todayEmptyHint.
  ///
  /// In ru, this message translates to:
  /// **'Нажми «Добавить», чтобы создать первую привычку или учебную цель'**
  String get todayEmptyHint;

  /// No description provided for @sectionHabits.
  ///
  /// In ru, this message translates to:
  /// **'Привычки'**
  String get sectionHabits;

  /// No description provided for @sectionStudy.
  ///
  /// In ru, this message translates to:
  /// **'Учёба'**
  String get sectionStudy;

  /// No description provided for @addHabit.
  ///
  /// In ru, this message translates to:
  /// **'Добавить'**
  String get addHabit;

  /// No description provided for @streakDays.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, =0{нет серии} one{{count} день} few{{count} дня} many{{count} дней} other{{count} дня}}'**
  String streakDays(int count);

  /// No description provided for @minutesShort.
  ///
  /// In ru, this message translates to:
  /// **'{count} мин'**
  String minutesShort(int count);

  /// No description provided for @habitTypeHabit.
  ///
  /// In ru, this message translates to:
  /// **'Привычка'**
  String get habitTypeHabit;

  /// No description provided for @habitTypeStudy.
  ///
  /// In ru, this message translates to:
  /// **'Учёба'**
  String get habitTypeStudy;

  /// No description provided for @detailCurrentStreak.
  ///
  /// In ru, this message translates to:
  /// **'Текущая серия'**
  String get detailCurrentStreak;

  /// No description provided for @detailBestStreak.
  ///
  /// In ru, this message translates to:
  /// **'Лучшая серия'**
  String get detailBestStreak;

  /// No description provided for @detailCompletion.
  ///
  /// In ru, this message translates to:
  /// **'За 30 дней'**
  String get detailCompletion;

  /// No description provided for @detailCalendar.
  ///
  /// In ru, this message translates to:
  /// **'Календарь выполнений'**
  String get detailCalendar;

  /// No description provided for @detailSchedule.
  ///
  /// In ru, this message translates to:
  /// **'Расписание'**
  String get detailSchedule;

  /// No description provided for @detailReminder.
  ///
  /// In ru, this message translates to:
  /// **'Напоминание'**
  String get detailReminder;

  /// No description provided for @detailNoReminder.
  ///
  /// In ru, this message translates to:
  /// **'Без напоминания'**
  String get detailNoReminder;

  /// No description provided for @detailEveryDay.
  ///
  /// In ru, this message translates to:
  /// **'Каждый день'**
  String get detailEveryDay;

  /// No description provided for @detailDescription.
  ///
  /// In ru, this message translates to:
  /// **'Описание'**
  String get detailDescription;

  /// No description provided for @detailTarget.
  ///
  /// In ru, this message translates to:
  /// **'Цель на день'**
  String get detailTarget;

  /// No description provided for @edit.
  ///
  /// In ru, this message translates to:
  /// **'Изменить'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get cancel;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить «{title}»?'**
  String deleteConfirmTitle(String title);

  /// No description provided for @deleteConfirmBody.
  ///
  /// In ru, this message translates to:
  /// **'История выполнений тоже будет удалена.'**
  String get deleteConfirmBody;

  /// No description provided for @editNewTitle.
  ///
  /// In ru, this message translates to:
  /// **'Новая цель'**
  String get editNewTitle;

  /// No description provided for @editEditTitle.
  ///
  /// In ru, this message translates to:
  /// **'Редактирование'**
  String get editEditTitle;

  /// No description provided for @editFieldTitle.
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get editFieldTitle;

  /// No description provided for @editFieldTitleHint.
  ///
  /// In ru, this message translates to:
  /// **'Например: 30 минут английского'**
  String get editFieldTitleHint;

  /// No description provided for @editFieldTitleError.
  ///
  /// In ru, this message translates to:
  /// **'Введите название'**
  String get editFieldTitleError;

  /// No description provided for @editFieldDescription.
  ///
  /// In ru, this message translates to:
  /// **'Описание (необязательно)'**
  String get editFieldDescription;

  /// No description provided for @editType.
  ///
  /// In ru, this message translates to:
  /// **'Тип'**
  String get editType;

  /// No description provided for @editIcon.
  ///
  /// In ru, this message translates to:
  /// **'Иконка'**
  String get editIcon;

  /// No description provided for @editColor.
  ///
  /// In ru, this message translates to:
  /// **'Цвет'**
  String get editColor;

  /// No description provided for @editDays.
  ///
  /// In ru, this message translates to:
  /// **'Дни недели'**
  String get editDays;

  /// No description provided for @editDaysError.
  ///
  /// In ru, this message translates to:
  /// **'Выберите хотя бы один день'**
  String get editDaysError;

  /// No description provided for @editTargetMinutes.
  ///
  /// In ru, this message translates to:
  /// **'Минут в день: {count}'**
  String editTargetMinutes(int count);

  /// No description provided for @editReminder.
  ///
  /// In ru, this message translates to:
  /// **'Напоминание'**
  String get editReminder;

  /// No description provided for @editReminderOff.
  ///
  /// In ru, this message translates to:
  /// **'Выключено'**
  String get editReminderOff;

  /// No description provided for @save.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get save;

  /// No description provided for @savedMessage.
  ///
  /// In ru, this message translates to:
  /// **'Сохранено'**
  String get savedMessage;

  /// No description provided for @statsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Статистика'**
  String get statsTitle;

  /// No description provided for @statsWeekRate.
  ///
  /// In ru, this message translates to:
  /// **'Выполнение за 7 дней'**
  String get statsWeekRate;

  /// No description provided for @statsCompletedTotal.
  ///
  /// In ru, this message translates to:
  /// **'Всего отметок'**
  String get statsCompletedTotal;

  /// No description provided for @statsActiveHabits.
  ///
  /// In ru, this message translates to:
  /// **'Активных целей'**
  String get statsActiveHabits;

  /// No description provided for @statsLast7Days.
  ///
  /// In ru, this message translates to:
  /// **'Последние 7 дней'**
  String get statsLast7Days;

  /// No description provided for @statsTopStreaks.
  ///
  /// In ru, this message translates to:
  /// **'Лучшие серии'**
  String get statsTopStreaks;

  /// No description provided for @statsEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Добавь цели, чтобы увидеть статистику'**
  String get statsEmpty;

  /// No description provided for @settingsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get settingsTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In ru, this message translates to:
  /// **'Оформление'**
  String get settingsAppearance;

  /// No description provided for @settingsTheme.
  ///
  /// In ru, this message translates to:
  /// **'Тема'**
  String get settingsTheme;

  /// No description provided for @themeSystem.
  ///
  /// In ru, this message translates to:
  /// **'Системная'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In ru, this message translates to:
  /// **'Светлая'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ru, this message translates to:
  /// **'Тёмная'**
  String get themeDark;

  /// No description provided for @settingsLanguage.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get settingsLanguage;

  /// No description provided for @settingsAbout.
  ///
  /// In ru, this message translates to:
  /// **'О приложении'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In ru, this message translates to:
  /// **'Версия {version}'**
  String settingsVersion(String version);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
