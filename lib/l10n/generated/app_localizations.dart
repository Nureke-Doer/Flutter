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
  /// **'Все привычки на сегодня выполнены! 🎉'**
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
  /// **'Нажми «Добавить», чтобы создать первую привычку'**
  String get todayEmptyHint;

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
  /// **'Календарь отметок (нажми на день, чтобы изменить)'**
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
  /// **'История отметок тоже будет удалена.'**
  String get deleteConfirmBody;

  /// No description provided for @editNewTitle.
  ///
  /// In ru, this message translates to:
  /// **'Новая привычка'**
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
  /// **'Например: Английский язык'**
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
  /// **'Дней выполнения'**
  String get statsCompletedTotal;

  /// No description provided for @statsActiveHabits.
  ///
  /// In ru, this message translates to:
  /// **'Активных привычек'**
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
  /// **'Добавь привычки, чтобы увидеть статистику'**
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

  /// No description provided for @detailMarkToday.
  ///
  /// In ru, this message translates to:
  /// **'Отметить сегодня'**
  String get detailMarkToday;

  /// No description provided for @detailDoneToday.
  ///
  /// In ru, this message translates to:
  /// **'Выполнено сегодня'**
  String get detailDoneToday;

  /// No description provided for @deletedMessage.
  ///
  /// In ru, this message translates to:
  /// **'Привычка удалена'**
  String get deletedMessage;

  /// No description provided for @undo.
  ///
  /// In ru, this message translates to:
  /// **'Отменить'**
  String get undo;

  /// No description provided for @errorLoading.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить данные'**
  String get errorLoading;

  /// No description provided for @retry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get retry;

  /// No description provided for @languageRussian.
  ///
  /// In ru, this message translates to:
  /// **'Русский'**
  String get languageRussian;

  /// No description provided for @languageEnglish.
  ///
  /// In ru, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @materialsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Учебные материалы'**
  String get materialsTitle;

  /// No description provided for @materialsSearchHint.
  ///
  /// In ru, this message translates to:
  /// **'Поиск книг: тема, автор, предмет…'**
  String get materialsSearchHint;

  /// No description provided for @materialsIntro.
  ///
  /// In ru, this message translates to:
  /// **'Найди книги и учебники для своих целей'**
  String get materialsIntro;

  /// No description provided for @materialsSuggestions.
  ///
  /// In ru, this message translates to:
  /// **'Популярные темы'**
  String get materialsSuggestions;

  /// No description provided for @materialsEmpty.
  ///
  /// In ru, this message translates to:
  /// **'По запросу «{query}» ничего не найдено'**
  String materialsEmpty(String query);

  /// No description provided for @materialsEmptyHint.
  ///
  /// In ru, this message translates to:
  /// **'Попробуй изменить запрос или написать его по-английски'**
  String get materialsEmptyHint;

  /// No description provided for @materialsLoadMoreError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить ещё'**
  String get materialsLoadMoreError;

  /// No description provided for @materialsFound.
  ///
  /// In ru, this message translates to:
  /// **'Найдено: {count}'**
  String materialsFound(int count);

  /// No description provided for @bookAuthors.
  ///
  /// In ru, this message translates to:
  /// **'Авторы'**
  String get bookAuthors;

  /// No description provided for @bookYear.
  ///
  /// In ru, this message translates to:
  /// **'Год первой публикации'**
  String get bookYear;

  /// No description provided for @bookPages.
  ///
  /// In ru, this message translates to:
  /// **'Страниц'**
  String get bookPages;

  /// No description provided for @bookEditions.
  ///
  /// In ru, this message translates to:
  /// **'Изданий'**
  String get bookEditions;

  /// No description provided for @bookSubjects.
  ///
  /// In ru, this message translates to:
  /// **'Темы'**
  String get bookSubjects;

  /// No description provided for @bookUnknownAuthor.
  ///
  /// In ru, this message translates to:
  /// **'Автор неизвестен'**
  String get bookUnknownAuthor;

  /// No description provided for @bookOpenLibrary.
  ///
  /// In ru, this message translates to:
  /// **'Источник: Open Library'**
  String get bookOpenLibrary;

  /// No description provided for @findMaterials.
  ///
  /// In ru, this message translates to:
  /// **'Подобрать материалы'**
  String get findMaterials;

  /// No description provided for @errorNetwork.
  ///
  /// In ru, this message translates to:
  /// **'Нет подключения к интернету'**
  String get errorNetwork;

  /// No description provided for @errorTimeout.
  ///
  /// In ru, this message translates to:
  /// **'Сервер не отвечает. Попробуй позже'**
  String get errorTimeout;

  /// No description provided for @errorServer.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка сервера ({code})'**
  String errorServer(String code);

  /// No description provided for @errorParsing.
  ///
  /// In ru, this message translates to:
  /// **'Сервер вернул некорректные данные'**
  String get errorParsing;

  /// No description provided for @errorUnknown.
  ///
  /// In ru, this message translates to:
  /// **'Что-то пошло не так'**
  String get errorUnknown;

  /// No description provided for @quoteOfDay.
  ///
  /// In ru, this message translates to:
  /// **'Цитата дня'**
  String get quoteOfDay;

  /// No description provided for @materialsTabSearch.
  ///
  /// In ru, this message translates to:
  /// **'Поиск'**
  String get materialsTabSearch;

  /// No description provided for @materialsTabSaved.
  ///
  /// In ru, this message translates to:
  /// **'Сохранённые'**
  String get materialsTabSaved;

  /// No description provided for @savedEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Здесь появятся сохранённые книги'**
  String get savedEmpty;

  /// No description provided for @savedEmptyHint.
  ///
  /// In ru, this message translates to:
  /// **'Нажми на закладку у книги — она будет доступна даже без интернета'**
  String get savedEmptyHint;

  /// No description provided for @addToSaved.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get addToSaved;

  /// No description provided for @removeFromSaved.
  ///
  /// In ru, this message translates to:
  /// **'Убрать из сохранённых'**
  String get removeFromSaved;

  /// No description provided for @offlineBanner.
  ///
  /// In ru, this message translates to:
  /// **'Нет сети — показаны сохранённые результаты от {date}'**
  String offlineBanner(String date);

  /// No description provided for @recentSearches.
  ///
  /// In ru, this message translates to:
  /// **'Недавние запросы'**
  String get recentSearches;

  /// No description provided for @clearHistory.
  ///
  /// In ru, this message translates to:
  /// **'Очистить'**
  String get clearHistory;

  /// No description provided for @settingsData.
  ///
  /// In ru, this message translates to:
  /// **'Данные'**
  String get settingsData;

  /// No description provided for @settingsClearCache.
  ///
  /// In ru, this message translates to:
  /// **'Очистить кэш'**
  String get settingsClearCache;

  /// No description provided for @settingsClearCacheHint.
  ///
  /// In ru, this message translates to:
  /// **'Сохранённые ответы API и история поиска'**
  String get settingsClearCacheHint;

  /// No description provided for @cacheCleared.
  ///
  /// In ru, this message translates to:
  /// **'Кэш очищен'**
  String get cacheCleared;

  /// No description provided for @settingsOfflineHint.
  ///
  /// In ru, this message translates to:
  /// **'Цели, настройки и сохранённые книги хранятся на устройстве и работают без интернета'**
  String get settingsOfflineHint;

  /// No description provided for @archive.
  ///
  /// In ru, this message translates to:
  /// **'В архив'**
  String get archive;

  /// No description provided for @unarchive.
  ///
  /// In ru, this message translates to:
  /// **'Вернуть из архива'**
  String get unarchive;

  /// No description provided for @archived.
  ///
  /// In ru, this message translates to:
  /// **'Привычка в архиве — история сохранена'**
  String get archived;

  /// No description provided for @unarchived.
  ///
  /// In ru, this message translates to:
  /// **'Привычка возвращена из архива'**
  String get unarchived;

  /// No description provided for @archivedBadge.
  ///
  /// In ru, this message translates to:
  /// **'В архиве'**
  String get archivedBadge;

  /// No description provided for @detailByMonth.
  ///
  /// In ru, this message translates to:
  /// **'По месяцам'**
  String get detailByMonth;

  /// No description provided for @detailFailures.
  ///
  /// In ru, this message translates to:
  /// **'Не выполнено'**
  String get detailFailures;

  /// No description provided for @detailRelapses.
  ///
  /// In ru, this message translates to:
  /// **'Срывов'**
  String get detailRelapses;

  /// No description provided for @detailHeatmap.
  ///
  /// In ru, this message translates to:
  /// **'Тепловая карта (20 недель)'**
  String get detailHeatmap;

  /// No description provided for @detailNoTarget.
  ///
  /// In ru, this message translates to:
  /// **'Без цели — любое число > 0 засчитывается'**
  String get detailNoTarget;

  /// No description provided for @detailSum.
  ///
  /// In ru, this message translates to:
  /// **'Всего {unit}'**
  String detailSum(String unit);

  /// No description provided for @detailTotalDone.
  ///
  /// In ru, this message translates to:
  /// **'Дней выполнено'**
  String get detailTotalDone;

  /// No description provided for @editCategory.
  ///
  /// In ru, this message translates to:
  /// **'Категория'**
  String get editCategory;

  /// No description provided for @editSchedule.
  ///
  /// In ru, this message translates to:
  /// **'Расписание'**
  String get editSchedule;

  /// No description provided for @editTarget.
  ///
  /// In ru, this message translates to:
  /// **'Цель на день'**
  String get editTarget;

  /// No description provided for @editTargetError.
  ///
  /// In ru, this message translates to:
  /// **'Введите число больше 0'**
  String get editTargetError;

  /// No description provided for @editUnit.
  ///
  /// In ru, this message translates to:
  /// **'Единица'**
  String get editUnit;

  /// No description provided for @editUnitHint.
  ///
  /// In ru, this message translates to:
  /// **'мин, стр., раз'**
  String get editUnitHint;

  /// No description provided for @entryAmountLabel.
  ///
  /// In ru, this message translates to:
  /// **'Сколько сделано'**
  String get entryAmountLabel;

  /// No description provided for @entryClear.
  ///
  /// In ru, this message translates to:
  /// **'Очистить'**
  String get entryClear;

  /// No description provided for @entryDone.
  ///
  /// In ru, this message translates to:
  /// **'Выполнил'**
  String get entryDone;

  /// No description provided for @entryFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не выполнил'**
  String get entryFailed;

  /// No description provided for @entryHeld.
  ///
  /// In ru, this message translates to:
  /// **'Удержался'**
  String get entryHeld;

  /// No description provided for @entryRelapsed.
  ///
  /// In ru, this message translates to:
  /// **'Сорвался'**
  String get entryRelapsed;

  /// No description provided for @entrySkipped.
  ///
  /// In ru, this message translates to:
  /// **'Пропуск (0)'**
  String get entrySkipped;

  /// No description provided for @entryEmpty.
  ///
  /// In ru, this message translates to:
  /// **'не отмечено'**
  String get entryEmpty;

  /// No description provided for @entryMoreValues.
  ///
  /// In ru, this message translates to:
  /// **'Другие значения'**
  String get entryMoreValues;

  /// No description provided for @entrySkipHint.
  ///
  /// In ru, this message translates to:
  /// **'«Пропуск» и пустой день не прерывают серию и не увеличивают её. Серию обрывает только ✘.'**
  String get entrySkipHint;

  /// No description provided for @entryTargetHint.
  ///
  /// In ru, this message translates to:
  /// **'Цель: {target}'**
  String entryTargetHint(String target);

  /// No description provided for @kindPositive.
  ///
  /// In ru, this message translates to:
  /// **'Действие'**
  String get kindPositive;

  /// No description provided for @kindQuit.
  ///
  /// In ru, this message translates to:
  /// **'Отказ'**
  String get kindQuit;

  /// No description provided for @kindNumeric.
  ///
  /// In ru, this message translates to:
  /// **'Число'**
  String get kindNumeric;

  /// No description provided for @kindPositiveHint.
  ///
  /// In ru, this message translates to:
  /// **'Полезное действие: ✔ — выполнил, ✘ — не выполнил.'**
  String get kindPositiveHint;

  /// No description provided for @kindQuitHint.
  ///
  /// In ru, this message translates to:
  /// **'Отказ от вредного: ✔ — удержался, ✘ — сорвался.'**
  String get kindQuitHint;

  /// No description provided for @kindNumericHint.
  ///
  /// In ru, this message translates to:
  /// **'Числовая: повторения, минуты, страницы. Число больше 0 — выполнено.'**
  String get kindNumericHint;

  /// No description provided for @monthColumn.
  ///
  /// In ru, this message translates to:
  /// **'Месяц'**
  String get monthColumn;

  /// No description provided for @sumColumn.
  ///
  /// In ru, this message translates to:
  /// **'Сумма'**
  String get sumColumn;

  /// No description provided for @noCategory.
  ///
  /// In ru, this message translates to:
  /// **'Без категории'**
  String get noCategory;

  /// No description provided for @scheduleDaily.
  ///
  /// In ru, this message translates to:
  /// **'Каждый день'**
  String get scheduleDaily;

  /// No description provided for @scheduleWeekdays.
  ///
  /// In ru, this message translates to:
  /// **'Дни недели'**
  String get scheduleWeekdays;

  /// No description provided for @scheduleTimesPerWeek.
  ///
  /// In ru, this message translates to:
  /// **'N раз в неделю'**
  String get scheduleTimesPerWeek;

  /// No description provided for @timesPerWeek.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} раз в неделю} few{{count} раза в неделю} many{{count} раз в неделю} other{{count} раза в неделю}}'**
  String timesPerWeek(int count);

  /// No description provided for @weekProgress.
  ///
  /// In ru, this message translates to:
  /// **'{done} из {total} за неделю'**
  String weekProgress(int done, int total);

  /// No description provided for @authEmail.
  ///
  /// In ru, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authEnterEmail.
  ///
  /// In ru, this message translates to:
  /// **'Введите email, чтобы восстановить пароль'**
  String get authEnterEmail;

  /// No description provided for @authErrorCancelled.
  ///
  /// In ru, this message translates to:
  /// **'Вход отменён'**
  String get authErrorCancelled;

  /// No description provided for @authErrorEmailInUse.
  ///
  /// In ru, this message translates to:
  /// **'Этот email уже зарегистрирован'**
  String get authErrorEmailInUse;

  /// No description provided for @authErrorInvalidEmail.
  ///
  /// In ru, this message translates to:
  /// **'Некорректный email'**
  String get authErrorInvalidEmail;

  /// No description provided for @authErrorTooManyRequests.
  ///
  /// In ru, this message translates to:
  /// **'Слишком много попыток. Попробуйте позже'**
  String get authErrorTooManyRequests;

  /// No description provided for @authErrorUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'Вход через аккаунт недоступен: Firebase не настроен'**
  String get authErrorUnavailable;

  /// No description provided for @authErrorWeakPassword.
  ///
  /// In ru, this message translates to:
  /// **'Пароль должен быть не короче 6 символов'**
  String get authErrorWeakPassword;

  /// No description provided for @authErrorWrongCredentials.
  ///
  /// In ru, this message translates to:
  /// **'Неверный email или пароль'**
  String get authErrorWrongCredentials;

  /// No description provided for @authFirebaseNotConfigured.
  ///
  /// In ru, this message translates to:
  /// **'Вход по email и Google появится после подключения Firebase (неделя 8). Сейчас можно работать без аккаунта.'**
  String get authFirebaseNotConfigured;

  /// No description provided for @authForgotPassword.
  ///
  /// In ru, this message translates to:
  /// **'Забыли пароль?'**
  String get authForgotPassword;

  /// No description provided for @authGoogle.
  ///
  /// In ru, this message translates to:
  /// **'Войти через Google'**
  String get authGoogle;

  /// No description provided for @authGuest.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить без аккаунта'**
  String get authGuest;

  /// No description provided for @authGuestHint.
  ///
  /// In ru, this message translates to:
  /// **'Данные хранятся только на этом устройстве'**
  String get authGuestHint;

  /// No description provided for @authGuestName.
  ///
  /// In ru, this message translates to:
  /// **'Гость'**
  String get authGuestName;

  /// No description provided for @authLeaveGuest.
  ///
  /// In ru, this message translates to:
  /// **'Выйти из гостевого режима'**
  String get authLeaveGuest;

  /// No description provided for @authName.
  ///
  /// In ru, this message translates to:
  /// **'Имя'**
  String get authName;

  /// No description provided for @authOr.
  ///
  /// In ru, this message translates to:
  /// **'или'**
  String get authOr;

  /// No description provided for @authPassword.
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get authPassword;

  /// No description provided for @authRegister.
  ///
  /// In ru, this message translates to:
  /// **'Регистрация'**
  String get authRegister;

  /// No description provided for @authResetSent.
  ///
  /// In ru, this message translates to:
  /// **'Письмо для сброса пароля отправлено'**
  String get authResetSent;

  /// No description provided for @authSignIn.
  ///
  /// In ru, this message translates to:
  /// **'Вход'**
  String get authSignIn;

  /// No description provided for @authSignOut.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get authSignOut;

  /// No description provided for @authSignOutBody.
  ///
  /// In ru, this message translates to:
  /// **'Привычки останутся на устройстве.'**
  String get authSignOutBody;

  /// No description provided for @authSignOutConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Выйти из аккаунта?'**
  String get authSignOutConfirm;

  /// No description provided for @authSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Привычки и учебные цели в одном месте'**
  String get authSubtitle;

  /// No description provided for @categoriesEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Категорий пока нет'**
  String get categoriesEmpty;

  /// No description provided for @categoriesHint.
  ///
  /// In ru, this message translates to:
  /// **'Перетащите категорию за ручку, чтобы изменить порядок'**
  String get categoriesHint;

  /// No description provided for @categoriesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Категории'**
  String get categoriesTitle;

  /// No description provided for @categoryAdd.
  ///
  /// In ru, this message translates to:
  /// **'Новая категория'**
  String get categoryAdd;

  /// No description provided for @categoryDeleteBody.
  ///
  /// In ru, this message translates to:
  /// **'Привычки не удалятся — они попадут в «Без категории».'**
  String get categoryDeleteBody;

  /// No description provided for @goalAdd.
  ///
  /// In ru, this message translates to:
  /// **'Новая цель'**
  String get goalAdd;

  /// No description provided for @goalAddProgress.
  ///
  /// In ru, this message translates to:
  /// **'Добавить прогресс вручную'**
  String get goalAddProgress;

  /// No description provided for @goalBook.
  ///
  /// In ru, this message translates to:
  /// **'Книга'**
  String get goalBook;

  /// No description provided for @goalBookHint.
  ///
  /// In ru, this message translates to:
  /// **'Сохраните книгу в «Учебных материалах», чтобы привязать её к цели'**
  String get goalBookHint;

  /// No description provided for @goalCompleted.
  ///
  /// In ru, this message translates to:
  /// **'Цель достигнута! 🎉'**
  String get goalCompleted;

  /// No description provided for @goalDaysLeft.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, =0{дедлайн сегодня} one{остался {count} день} few{осталось {count} дня} many{осталось {count} дней} other{осталось {count} дня}}'**
  String goalDaysLeft(int count);

  /// No description provided for @goalDaysLeftLabel.
  ///
  /// In ru, this message translates to:
  /// **'Дней до дедлайна'**
  String get goalDaysLeftLabel;

  /// No description provided for @goalDeadline.
  ///
  /// In ru, this message translates to:
  /// **'до {date}'**
  String goalDeadline(String date);

  /// No description provided for @goalDeadlineLabel.
  ///
  /// In ru, this message translates to:
  /// **'Дедлайн'**
  String get goalDeadlineLabel;

  /// No description provided for @goalEdit.
  ///
  /// In ru, this message translates to:
  /// **'Редактирование цели'**
  String get goalEdit;

  /// No description provided for @goalLinkedHabits.
  ///
  /// In ru, this message translates to:
  /// **'Привязанные привычки'**
  String get goalLinkedHabits;

  /// No description provided for @goalLinkedHint.
  ///
  /// In ru, this message translates to:
  /// **'Прогресс считается автоматически: числовые привычки добавляют сумму, обычные — по 1 за каждый ✔.'**
  String get goalLinkedHint;

  /// No description provided for @goalManualProgress.
  ///
  /// In ru, this message translates to:
  /// **'Добавлено вручную'**
  String get goalManualProgress;

  /// No description provided for @goalNew.
  ///
  /// In ru, this message translates to:
  /// **'Новая учебная цель'**
  String get goalNew;

  /// No description provided for @goalNoBook.
  ///
  /// In ru, this message translates to:
  /// **'Без книги'**
  String get goalNoBook;

  /// No description provided for @goalNoLinkedHabits.
  ///
  /// In ru, this message translates to:
  /// **'Нет — прогресс только вручную'**
  String get goalNoLinkedHabits;

  /// No description provided for @goalOverdue.
  ///
  /// In ru, this message translates to:
  /// **'Дедлайн прошёл'**
  String get goalOverdue;

  /// No description provided for @goalPerDay.
  ///
  /// In ru, this message translates to:
  /// **'нужно {amount} в день'**
  String goalPerDay(String amount);

  /// No description provided for @goalRemaining.
  ///
  /// In ru, this message translates to:
  /// **'Осталось {unit}'**
  String goalRemaining(String unit);

  /// No description provided for @goalTarget.
  ///
  /// In ru, this message translates to:
  /// **'Сколько нужно'**
  String get goalTarget;

  /// No description provided for @goalTitleHint.
  ///
  /// In ru, this message translates to:
  /// **'Например: Прочитать 300 страниц'**
  String get goalTitleHint;

  /// No description provided for @goalsEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Учебных целей пока нет'**
  String get goalsEmpty;

  /// No description provided for @goalsEmptyHint.
  ///
  /// In ru, this message translates to:
  /// **'Создайте цель с дедлайном и привяжите к ней привычки'**
  String get goalsEmptyHint;

  /// No description provided for @goalsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Учебные цели'**
  String get goalsTitle;

  /// No description provided for @habitsCount.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, =0{нет привычек} one{{count} привычка} few{{count} привычки} many{{count} привычек} other{{count} привычки}}'**
  String habitsCount(int count);

  /// No description provided for @habitsEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Привычек пока нет'**
  String get habitsEmpty;

  /// No description provided for @navGoals.
  ///
  /// In ru, this message translates to:
  /// **'Цели'**
  String get navGoals;

  /// No description provided for @navHabits.
  ///
  /// In ru, this message translates to:
  /// **'Привычки'**
  String get navHabits;

  /// No description provided for @navProfile.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get navProfile;

  /// No description provided for @notFound.
  ///
  /// In ru, this message translates to:
  /// **'Страница не найдена'**
  String get notFound;

  /// No description provided for @selectHabitHint.
  ///
  /// In ru, this message translates to:
  /// **'Выберите привычку слева'**
  String get selectHabitHint;

  /// No description provided for @settingsGamification.
  ///
  /// In ru, this message translates to:
  /// **'Включить геймификацию'**
  String get settingsGamification;

  /// No description provided for @settingsGamificationHint.
  ///
  /// In ru, this message translates to:
  /// **'Свои метрики (например, Power и Money), которые растут от выполненных привычек'**
  String get settingsGamificationHint;

  /// No description provided for @showArchived.
  ///
  /// In ru, this message translates to:
  /// **'Архив ({count})'**
  String showArchived(int count);
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
