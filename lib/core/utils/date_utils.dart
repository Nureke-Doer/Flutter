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
