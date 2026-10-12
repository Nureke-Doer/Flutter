// Неделя 1. Задача 3 — Коллекции: List, Set, Map и функции высшего порядка.
// Запуск: dart run dart_tasks/task3_collections.dart

/// Убирает время из даты, оставляя только день.
DateTime dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Считает текущую серию (streak): сколько дней подряд до [today]
/// включительно привычка была выполнена.
int currentStreak(Iterable<DateTime> completions, DateTime today) {
  final days = completions.map(dayOnly).toSet();
  var streak = 0;
  var cursor = dayOnly(today);
  while (days.contains(cursor)) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}

/// Группирует учебные сессии по предмету и суммирует минуты.
Map<String, int> minutesBySubject(
  List<(String subject, int minutes)> sessions,
) {
  final result = <String, int>{};
  for (final (subject, minutes) in sessions) {
    result.update(subject, (value) => value + minutes, ifAbsent: () => minutes);
  }
  return result;
}

/// Возвращает предметы, отсортированные по убыванию времени.
List<String> topSubjects(Map<String, int> minutes, {int limit = 3}) {
  final entries = minutes.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return entries.take(limit).map((e) => e.key).toList();
}

void main() {
  final today = DateTime(2026, 9, 10);
  final completions = [
    DateTime(2026, 9, 10, 8),
    DateTime(2026, 9, 9, 21),
    DateTime(2026, 9, 8, 7),
    DateTime(2026, 9, 6),
  ];
  print('Серия: ${currentStreak(completions, today)} дня'); // 3

  final sessions = [
    ('Математика', 40),
    ('Английский', 30),
    ('Математика', 25),
    ('Flutter', 90),
  ];
  final grouped = minutesBySubject(sessions);
  print(grouped); // {Математика: 65, Английский: 30, Flutter: 90}
  print('Топ: ${topSubjects(grouped, limit: 2)}'); // [Flutter, Математика]

  // where / map / fold / any / every
  final total = grouped.values.fold<int>(0, (sum, m) => sum + m);
  print('Всего минут: $total');
  print('Есть сессии > 60 мин: ${grouped.values.any((m) => m > 60)}');
}
