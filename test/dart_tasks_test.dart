import 'package:flutter_test/flutter_test.dart';

import '../dart_tasks/task1_null_safety.dart' as t1;
import '../dart_tasks/task2_classes.dart' as t2;
import '../dart_tasks/task3_collections.dart' as t3;
import '../dart_tasks/task4_async.dart' as t4;

void main() {
  group('Задача 1: null safety', () {
    test('safeLength', () {
      expect(t1.safeLength(null), 0);
      expect(t1.safeLength('abc'), 3);
    });
    test('parseStudyMinutes', () {
      expect(t1.parseStudyMinutes(' 30 '), 30);
      expect(t1.parseStudyMinutes('-5'), isNull);
      expect(t1.parseStudyMinutes(null), isNull);
    });
  });

  group('Задача 2: классы', () {
    test('HabitGoal не превышает цель', () {
      final h = t2.HabitGoal('Вода', target: 2)
        ..markDone()
        ..markDone()
        ..markDone();
      expect(h.done, 2);
      expect(h.progress, 1.0);
    });
    test('StudyGoal бросает ошибку на неположительные минуты', () {
      final g = t2.StudyGoal('Dart', targetMinutes: 60);
      expect(() => g.addMinutes(0), throwsArgumentError);
      g.addMinutes(30);
      expect(g.progress, 0.5);
    });
  });

  group('Задача 3: коллекции', () {
    test('currentStreak', () {
      final today = DateTime(2026, 9, 10);
      expect(
        t3.currentStreak([
          DateTime(2026, 9, 10),
          DateTime(2026, 9, 9),
          DateTime(2026, 9, 7),
        ], today),
        2,
      );
      expect(t3.currentStreak([], today), 0);
    });
    test('minutesBySubject и topSubjects', () {
      final m = t3.minutesBySubject([('A', 10), ('B', 30), ('A', 25)]);
      expect(m, {'A': 35, 'B': 30});
      expect(t3.topSubjects(m, limit: 1), ['A']);
    });
  });

  group('Задача 4: async', () {
    test('loadQuoteSafely возвращает запасной текст при ошибке', () async {
      expect(await t4.loadQuoteSafely(fail: true), contains('недоступна'));
    });
    test('pomodoro отдаёт обратный отсчёт', () async {
      final values = await t4
          .pomodoro(2, tick: const Duration(milliseconds: 1))
          .toList();
      expect(values, [2, 1, 0]);
    });
  });
}
