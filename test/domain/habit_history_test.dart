import 'package:flutter_test/flutter_test.dart';
import 'package:habit_study_tracker/core/utils/date_utils.dart';
import 'package:habit_study_tracker/domain/entities/habit.dart';
import 'package:habit_study_tracker/domain/entities/habit_entry.dart';
import 'package:habit_study_tracker/domain/entities/habit_history.dart';

void main() {
  // Среда, 9 сентября 2026.
  final today = DateTime(2026, 9, 9);
  DateTime ago(int days) => addDays(today, -days);

  const done = EntryDone();
  const failed = EntryFailed();
  const skip = EntrySkipped();

  HabitHistory history(Map<int, EntryValue> byDaysAgo) =>
      HabitHistory({for (final e in byDaysAgo.entries) ago(e.key): e.value});

  group('EntryValue', () {
    test('кодируется в строку и обратно', () {
      for (final v in [done, failed, skip, const EntryAmount(12.5)]) {
        expect(EntryValue.decode(v.encode()), v);
      }
      expect(EntryValue.decode('мусор'), isNull);
      expect(EntryValue.decode('n:abc'), isNull);
    });

    test('число > 0 — выполнено, 0 — нейтрально', () {
      expect(const EntryAmount(3).isSuccess, isTrue);
      expect(const EntryAmount(0).isSuccess, isFalse);
      expect(const EntryAmount(0).isNeutral, isTrue);
      expect(skip.isNeutral, isTrue);
      expect(failed.isFailure, isTrue);
      expect(done.amount, 0);
    });
  });

  group('currentStreak', () {
    test('считает выполненные дни после последнего ✘', () {
      final h = history({0: done, 1: done, 2: done, 3: failed, 4: done});
      expect(h.currentStreak, 3);
    });

    test('пустые дни не прерывают серию и не увеличивают её', () {
      // Дни 1 и 3 не отмечены.
      final h = history({0: done, 2: done, 4: done});
      expect(h.currentStreak, 3);
    });

    test('пропуск (0) не прерывает и не увеличивает серию', () {
      final h = history({0: done, 1: skip, 2: const EntryAmount(0), 3: done});
      expect(h.currentStreak, 2);
    });

    test('✘ сегодня обнуляет серию', () {
      expect(history({0: failed, 1: done, 2: done}).currentStreak, 0);
    });

    test('числовые значения > 0 увеличивают серию', () {
      final h = history({0: const EntryAmount(20), 1: const EntryAmount(5)});
      expect(h.currentStreak, 2);
    });

    test('пустая история — серия 0', () {
      expect(HabitHistory.empty.currentStreak, 0);
    });
  });

  test('bestStreak находит самую длинную серию между ✘', () {
    final h = history({
      10: done,
      9: done,
      8: skip,
      7: done,
      6: done,
      5: failed,
      2: done,
      1: done,
    });
    expect(h.bestStreak, 4);
    expect(h.currentStreak, 2);
  });

  test('итоги: дни выполнения, срывы, сумма', () {
    final h = history({
      0: const EntryAmount(10),
      1: const EntryAmount(2.5),
      2: failed,
      3: skip,
    });
    expect(h.successCount, 2);
    expect(h.failureCount, 1);
    expect(h.totalAmount, 12.5);
    expect(h.amountSince(ago(1)), 12.5);
    expect(h.successesSince(ago(0)), 1);
  });

  test('withValue добавляет и очищает отметку, не меняя исходную', () {
    final h = history({1: done});
    final added = h.withValue(today, failed);
    expect(added.valueOn(today), failed);
    expect(h.valueOn(today), isNull);
    expect(added.withValue(today, null).valueOn(today), isNull);
  });

  test('monthly группирует по месяцам от новых к старым', () {
    final h = HabitHistory({
      DateTime(2026, 8, 30): const EntryAmount(5),
      DateTime(2026, 8, 31): failed,
      DateTime(2026, 9, 1): const EntryAmount(7),
    });
    expect(h.monthly.map((m) => m.month), [
      DateTime(2026, 9),
      DateTime(2026, 8),
    ]);
    expect(h.monthly.last.amount, 5);
    expect(h.monthly.last.failures, 1);
    expect(h.monthly.first.successes, 1);
  });

  test('successesInWeek считает выполнения с понедельника', () {
    // 09.09.2026 — среда; понедельник — 07.09.
    final h = history({0: done, 2: done, 3: done});
    expect(h.successesInWeek(today), 2);
  });

  group('completionRate', () {
    Habit habit({HabitSchedule schedule = const HabitSchedule.daily()}) =>
        Habit(id: '1', title: 'Тест', createdAt: ago(30), schedule: schedule);

    test('выполненные / запланированные, сегодня без отметки не считается', () {
      // 6 прошедших дней, выполнено 3.
      final h = history({1: done, 2: done, 3: done});
      expect(h.completionRate(habit(), today), closeTo(0.5, 0.001));
    });

    test('пропуски не учитываются', () {
      final h = history({1: done, 2: skip, 3: skip, 4: skip, 5: skip, 6: skip});
      expect(h.completionRate(habit(), today), 1);
    });

    test('дни недели: незапланированные дни не считаются', () {
      // Только Пн/Ср/Пт; среда (сегодня) отмечена, пн (07.09) — да, пт (04.09) — нет.
      final h = history({0: done, 2: done});
      final rate = h.completionRate(
        habit(schedule: const HabitSchedule.weekdays({1, 3, 5})),
        today,
      );
      expect(rate, closeTo(2 / 3, 0.001));
    });

    test('N раз в неделю: не больше 100%', () {
      final h = history({0: done, 1: done, 2: done, 3: done});
      final rate = h.completionRate(
        habit(schedule: const HabitSchedule.timesPerWeek(3)),
        today,
      );
      expect(rate, 1);
    });

    test('0, если привычка создана сегодня и не отмечена', () {
      final h = HabitHistory.empty;
      final fresh = Habit(id: 'x', title: 'X', createdAt: today);
      expect(h.completionRate(fresh, today), 0);
    });
  });

  test('расписание: дни недели и N раз в неделю', () {
    const weekdays = HabitSchedule.weekdays({1, 3});
    expect(weekdays.isScheduledOn(DateTime(2026, 9, 7)), isTrue); // пн
    expect(weekdays.isScheduledOn(DateTime(2026, 9, 8)), isFalse); // вт
    expect(
      const HabitSchedule.timesPerWeek(2).isScheduledOn(DateTime(2026, 9, 8)),
      isTrue,
    );
  });

  test('copyWith позволяет обнулить nullable-поля', () {
    final h = Habit(
      id: '1',
      title: 'A',
      createdAt: today,
      reminderMinutes: 600,
      categoryId: 'c',
    );
    expect(h.copyWith(reminderMinutes: () => null).reminderMinutes, isNull);
    expect(h.copyWith(title: 'B').reminderMinutes, 600);
    expect(h.copyWith(categoryId: () => null).categoryId, isNull);
  });

  test('daysBetween не ломается при переходе на летнее время', () {
    expect(daysBetween(DateTime(2026, 3, 28), DateTime(2026, 3, 30)), 2);
    expect(daysBetween(DateTime(2026, 10, 24), DateTime(2026, 10, 26)), 2);
  });
}
