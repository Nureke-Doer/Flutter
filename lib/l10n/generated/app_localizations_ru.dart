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
  String get todayAllDone => 'Все цели на сегодня выполнены! 🎉';

  @override
  String get todayKeepGoing => 'Продолжай — ты на верном пути!';

  @override
  String get todayEmpty => 'На сегодня ничего не запланировано';

  @override
  String get todayEmptyHint =>
      'Нажми «Добавить», чтобы создать первую привычку или учебную цель';

  @override
  String get sectionHabits => 'Привычки';

  @override
  String get sectionStudy => 'Учёба';

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
  String minutesShort(int count) {
    return '$count мин';
  }

  @override
  String get habitTypeHabit => 'Привычка';

  @override
  String get habitTypeStudy => 'Учёба';

  @override
  String get detailCurrentStreak => 'Текущая серия';

  @override
  String get detailBestStreak => 'Лучшая серия';

  @override
  String get detailCompletion => 'За 30 дней';

  @override
  String get detailCalendar => 'Календарь выполнений';

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
  String get deleteConfirmBody => 'История выполнений тоже будет удалена.';

  @override
  String get editNewTitle => 'Новая цель';

  @override
  String get editEditTitle => 'Редактирование';

  @override
  String get editFieldTitle => 'Название';

  @override
  String get editFieldTitleHint => 'Например: 30 минут английского';

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
  String editTargetMinutes(int count) {
    return 'Минут в день: $count';
  }

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
  String get statsCompletedTotal => 'Всего отметок';

  @override
  String get statsActiveHabits => 'Активных целей';

  @override
  String get statsLast7Days => 'Последние 7 дней';

  @override
  String get statsTopStreaks => 'Лучшие серии';

  @override
  String get statsEmpty => 'Добавь цели, чтобы увидеть статистику';

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
  String get deletedMessage => 'Цель удалена';

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
}
