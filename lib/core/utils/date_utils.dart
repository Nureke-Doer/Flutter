/// Вспомогательные функции для работы с датами без учёта времени.
///
/// Везде используем `DateTime(y, m, d ± n)`, а не `subtract(Duration(days: n))`,
/// чтобы переход на летнее/зимнее время не «сдвигал» дни.
library;

/// Отбрасывает время, оставляя только дату (полночь по локальному времени).
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Дата, смещённая на [days] дней (может быть отрицательным).
DateTime addDays(DateTime d, int days) =>
    DateTime(d.year, d.month, d.day + days);

/// Совпадают ли две даты (без учёта времени).
bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Последние [count] дней, заканчивая [today] (по возрастанию).
List<DateTime> lastDays(DateTime today, int count) =>
    List.generate(count, (i) => addDays(today, i - count + 1));

/// Понедельник недели, в которую входит [day].
DateTime startOfWeek(DateTime day) => addDays(day, -(day.weekday - 1));

/// Первый день месяца.
DateTime startOfMonth(DateTime day) => DateTime(day.year, day.month);

/// Дата в формате `yyyy-MM-dd` — не зависит от часового пояса,
/// удобна как ключ в хранилище и легко читается при отладке.
String formatDay(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

/// Обратное к [formatDay]: `yyyy-MM-dd` → дата (полночь, локальное время).
DateTime parseDay(String s) => dateOnly(DateTime.parse(s));

/// Количество дней от [from] до [to] (без учёта времени).
///
/// Считаем в UTC: в локальном времени при переходе на летнее время
/// между двумя полуночами 23 часа, и `inDays` дал бы на день меньше.
int daysBetween(DateTime from, DateTime to) => DateTime.utc(
  to.year,
  to.month,
  to.day,
).difference(DateTime.utc(from.year, from.month, from.day)).inDays;
