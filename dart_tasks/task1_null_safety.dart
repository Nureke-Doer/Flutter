// Неделя 1. Задача 1 — Null safety.
// Запуск: dart run dart_tasks/task1_null_safety.dart

/// Возвращает длину строки или 0, если строка равна null.
/// Демонстрирует оператор `?.` и оператор `??`.
int safeLength(String? text) => text?.length ?? 0;

/// Возвращает приветствие. Если имя не передано — «гость».
String greet([String? name]) => 'Привет, ${name ?? 'гость'}!';

/// Пытается превратить строку в число минут учёбы.
/// Возвращает null, если строка некорректна или число отрицательное.
int? parseStudyMinutes(String? input) {
  if (input == null) return null;
  final value = int.tryParse(input.trim());
  if (value == null || value < 0) return null;
  return value;
}

/// `late` — переменная будет инициализирована позже, но до первого чтения.
class StudySession {
  late final DateTime finishedAt;

  void finish(DateTime time) => finishedAt = time;
}

void main() {
  print(safeLength(null)); // 0
  print(safeLength('Flutter')); // 7
  print(greet()); // Привет, гость!
  print(greet('Нурым')); // Привет, Нурым!
  print(parseStudyMinutes(' 45 ')); // 45
  print(parseStudyMinutes('abc')); // null

  final session = StudySession()..finish(DateTime(2026, 9, 1, 18));
  print('Сессия завершена: ${session.finishedAt}');

  // Оператор `!` используем только когда уверены, что значение не null.
  final String? maybeTitle =
      parseStudyMinutes('10') == null ? null : 'Английский';
  print(maybeTitle!.toUpperCase());
}
