// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Habit & Study Tracker';

  @override
  String get navToday => 'Сегодня';

  @override
  String get navStatistics => 'Статистика';

  @override
  String get navMaterials => 'Материалы';

  @override
  String get navSettings => 'Настройки';

  @override
  String get todayTitle => 'Сегодня';

  @override
  String todayProgress(int done, int total) {
    return 'Выполнено $done из $total';
  }

  @override
  String get todayAllDone => 'Все привычки на сегодня выполнены! 🎉';

  @override
  String get todayKeepGoing => 'Продолжай — ты на верном пути!';

  @override
  String get todayEmpty => 'На сегодня ничего не запланировано';

  @override
  String get todayEmptyHint =>
      'Нажми «Добавить», чтобы создать первую привычку';

  @override
  String get addHabit => 'Добавить';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня',
      many: '$count дней',
      few: '$count дня',
      one: '$count день',
      zero: 'нет серии',
    );
    return '$_temp0';
  }

  @override
  String get detailCurrentStreak => 'Текущая серия';

  @override
  String get detailBestStreak => 'Лучшая серия';

  @override
  String get detailCompletion => 'За 30 дней';

  @override
  String get detailCalendar =>
      'Календарь отметок (нажми на день, чтобы изменить)';

  @override
  String get detailSchedule => 'Расписание';

  @override
  String get detailReminder => 'Напоминание';

  @override
  String get detailNoReminder => 'Без напоминания';

  @override
  String get detailEveryDay => 'Каждый день';

  @override
  String get detailDescription => 'Описание';

  @override
  String get detailTarget => 'Цель на день';

  @override
  String get edit => 'Изменить';

  @override
  String get delete => 'Удалить';

  @override
  String get cancel => 'Отмена';

  @override
  String deleteConfirmTitle(String title) {
    return 'Удалить «$title»?';
  }

  @override
  String get deleteConfirmBody => 'История отметок тоже будет удалена.';

  @override
  String get editNewTitle => 'Новая привычка';

  @override
  String get editEditTitle => 'Редактирование';

  @override
  String get editFieldTitle => 'Название';

  @override
  String get editFieldTitleHint => 'Например: Английский язык';

  @override
  String get editFieldTitleError => 'Введите название';

  @override
  String get editFieldDescription => 'Описание (необязательно)';

  @override
  String get editType => 'Тип';

  @override
  String get editIcon => 'Иконка';

  @override
  String get editColor => 'Цвет';

  @override
  String get editDays => 'Дни недели';

  @override
  String get editDaysError => 'Выберите хотя бы один день';

  @override
  String get editReminder => 'Напоминание';

  @override
  String get editReminderOff => 'Выключено';

  @override
  String get save => 'Сохранить';

  @override
  String get savedMessage => 'Сохранено';

  @override
  String get statsTitle => 'Статистика';

  @override
  String get statsWeekRate => 'Выполнение за 7 дней';

  @override
  String get statsCompletedTotal => 'Дней выполнения';

  @override
  String get statsActiveHabits => 'Активных привычек';

  @override
  String get statsLast7Days => 'Последние 7 дней';

  @override
  String get statsTopStreaks => 'Лучшие серии';

  @override
  String get statsEmpty => 'Добавь привычки, чтобы увидеть статистику';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsAppearance => 'Оформление';

  @override
  String get settingsTheme => 'Тема';

  @override
  String get themeSystem => 'Системная';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsAbout => 'О приложении';

  @override
  String settingsVersion(String version) {
    return 'Версия $version';
  }

  @override
  String get detailMarkToday => 'Отметить сегодня';

  @override
  String get detailDoneToday => 'Выполнено сегодня';

  @override
  String get deletedMessage => 'Привычка удалена';

  @override
  String get undo => 'Отменить';

  @override
  String get errorLoading => 'Не удалось загрузить данные';

  @override
  String get retry => 'Повторить';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageEnglish => 'English';

  @override
  String get materialsTitle => 'Учебные материалы';

  @override
  String get materialsSearchHint => 'Поиск книг: тема, автор, предмет…';

  @override
  String get materialsIntro => 'Найди книги и учебники для своих целей';

  @override
  String get materialsSuggestions => 'Популярные темы';

  @override
  String materialsEmpty(String query) {
    return 'По запросу «$query» ничего не найдено';
  }

  @override
  String get materialsEmptyHint =>
      'Попробуй изменить запрос или написать его по-английски';

  @override
  String get materialsLoadMoreError => 'Не удалось загрузить ещё';

  @override
  String materialsFound(int count) {
    return 'Найдено: $count';
  }

  @override
  String get bookAuthors => 'Авторы';

  @override
  String get bookYear => 'Год первой публикации';

  @override
  String get bookPages => 'Страниц';

  @override
  String get bookEditions => 'Изданий';

  @override
  String get bookSubjects => 'Темы';

  @override
  String get bookUnknownAuthor => 'Автор неизвестен';

  @override
  String get bookOpenLibrary => 'Источник: Open Library';

  @override
  String get findMaterials => 'Подобрать материалы';

  @override
  String get errorNetwork => 'Нет подключения к интернету';

  @override
  String get errorTimeout => 'Сервер не отвечает. Попробуй позже';

  @override
  String errorServer(String code) {
    return 'Ошибка сервера ($code)';
  }

  @override
  String get errorParsing => 'Сервер вернул некорректные данные';

  @override
  String get errorUnknown => 'Что-то пошло не так';

  @override
  String get quoteOfDay => 'Цитата дня';

  @override
  String get materialsTabSearch => 'Поиск';

  @override
  String get materialsTabSaved => 'Сохранённые';

  @override
  String get savedEmpty => 'Здесь появятся сохранённые книги';

  @override
  String get savedEmptyHint =>
      'Нажми на закладку у книги — она будет доступна даже без интернета';

  @override
  String get addToSaved => 'Сохранить';

  @override
  String get removeFromSaved => 'Убрать из сохранённых';

  @override
  String offlineBanner(String date) {
    return 'Нет сети — показаны сохранённые результаты от $date';
  }

  @override
  String get recentSearches => 'Недавние запросы';

  @override
  String get clearHistory => 'Очистить';

  @override
  String get settingsData => 'Данные';

  @override
  String get settingsClearCache => 'Очистить кэш';

  @override
  String get settingsClearCacheHint =>
      'Сохранённые ответы API и история поиска';

  @override
  String get cacheCleared => 'Кэш очищен';

  @override
  String get settingsOfflineHint =>
      'Цели, настройки и сохранённые книги хранятся на устройстве и работают без интернета';

  @override
  String get archive => 'В архив';

  @override
  String get unarchive => 'Вернуть из архива';

  @override
  String get archived => 'Привычка в архиве — история сохранена';

  @override
  String get unarchived => 'Привычка возвращена из архива';

  @override
  String get archivedBadge => 'В архиве';

  @override
  String get detailByMonth => 'По месяцам';

  @override
  String get detailFailures => 'Не выполнено';

  @override
  String get detailRelapses => 'Срывов';

  @override
  String get detailHeatmap => 'Тепловая карта (20 недель)';

  @override
  String get detailNoTarget => 'Без цели — любое число > 0 засчитывается';

  @override
  String detailSum(String unit) {
    return 'Всего $unit';
  }

  @override
  String get detailTotalDone => 'Дней выполнено';

  @override
  String get editCategory => 'Категория';

  @override
  String get editSchedule => 'Расписание';

  @override
  String get editTarget => 'Цель на день';

  @override
  String get editTargetError => 'Введите число больше 0';

  @override
  String get editUnit => 'Единица';

  @override
  String get editUnitHint => 'мин, стр., раз';

  @override
  String get entryAmountLabel => 'Сколько сделано';

  @override
  String get entryClear => 'Очистить';

  @override
  String get entryDone => 'Выполнил';

  @override
  String get entryFailed => 'Не выполнил';

  @override
  String get entryHeld => 'Удержался';

  @override
  String get entryRelapsed => 'Сорвался';

  @override
  String get entrySkipped => 'Пропуск (0)';

  @override
  String get entryEmpty => 'не отмечено';

  @override
  String get entryMoreValues => 'Другие значения';

  @override
  String get entrySkipHint =>
      '«Пропуск» и пустой день не прерывают серию и не увеличивают её. Серию обрывает только ✘.';

  @override
  String entryTargetHint(String target) {
    return 'Цель: $target';
  }

  @override
  String get kindPositive => 'Действие';

  @override
  String get kindQuit => 'Отказ';

  @override
  String get kindNumeric => 'Число';

  @override
  String get kindPositiveHint =>
      'Полезное действие: ✔ — выполнил, ✘ — не выполнил.';

  @override
  String get kindQuitHint => 'Отказ от вредного: ✔ — удержался, ✘ — сорвался.';

  @override
  String get kindNumericHint =>
      'Числовая: повторения, минуты, страницы. Число больше 0 — выполнено.';

  @override
  String get monthColumn => 'Месяц';

  @override
  String get sumColumn => 'Сумма';

  @override
  String get noCategory => 'Без категории';

  @override
  String get scheduleDaily => 'Каждый день';

  @override
  String get scheduleWeekdays => 'Дни недели';

  @override
  String get scheduleTimesPerWeek => 'N раз в неделю';

  @override
  String timesPerWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count раза в неделю',
      many: '$count раз в неделю',
      few: '$count раза в неделю',
      one: '$count раз в неделю',
    );
    return '$_temp0';
  }

  @override
  String weekProgress(int done, int total) {
    return '$done из $total за неделю';
  }
}
