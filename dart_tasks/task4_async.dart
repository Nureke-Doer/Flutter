// Неделя 1. Задача 4 — async/await, Future, Stream, обработка ошибок.
// Запуск: dart run dart_tasks/task4_async.dart

/// Имитация загрузки мотивационной цитаты с сервера.
Future<String> fetchQuote({bool fail = false}) async {
  await Future<void>.delayed(const Duration(milliseconds: 300));
  if (fail) throw Exception('Нет соединения с сервером');
  return 'Маленькие шаги каждый день дают большой результат.';
}

/// Загружает цитату и возвращает запасной текст при ошибке.
Future<String> loadQuoteSafely({bool fail = false}) async {
  try {
    return await fetchQuote(fail: fail).timeout(const Duration(seconds: 2));
  } catch (e) {
    return 'Цитата недоступна ($e)';
  }
}

/// Stream — таймер Помодоро, который отдаёт оставшиеся секунды.
Stream<int> pomodoro(
  int seconds, {
  Duration tick = const Duration(seconds: 1),
}) async* {
  for (var left = seconds; left >= 0; left--) {
    yield left;
    if (left > 0) await Future<void>.delayed(tick);
  }
}

/// Параллельная загрузка нескольких источников через Future.wait.
Future<List<int>> loadStatsInParallel() {
  Future<int> load(int value, int ms) =>
      Future.delayed(Duration(milliseconds: ms), () => value);
  return Future.wait([load(5, 200), load(12, 100), load(3, 150)]);
}

Future<void> main() async {
  print(await loadQuoteSafely());
  print(await loadQuoteSafely(fail: true));

  final stats = await loadStatsInParallel();
  print('Статистика: $stats');

  await for (final left in pomodoro(
    3,
    tick: const Duration(milliseconds: 200),
  )) {
    print('Осталось: $left c');
  }
  print('Помодоро завершён!');
}
