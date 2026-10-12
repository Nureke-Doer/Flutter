import 'package:flutter_test/flutter_test.dart';
import 'package:habit_study_tracker/core/utils/date_utils.dart';
import 'package:habit_study_tracker/domain/entities/habit.dart';
import 'package:habit_study_tracker/domain/entities/habit_entry.dart';
import 'package:habit_study_tracker/domain/entities/habit_history.dart';
import 'package:habit_study_tracker/domain/entities/metric.dart';
import 'package:habit_study_tracker/domain/services/metric_calculator.dart';

void main() {
  final today = DateTime(2026, 9, 9);
  DateTime ago(int d) => addDays(today, -d);

  final sport = Habit(id: 'sport', title: 'Спорт', createdAt: ago(30));
  final study = Habit(id: 'study', title: 'Учёба', createdAt: ago(30));
  final smoke = Habit(
    id: 'smoke',
    title: 'Не курить',
    kind: HabitKind.quit,
    createdAt: ago(30),
  );
  final pages = Habit(
    id: 'pages',
    title: 'Чтение',
    kind: HabitKind.numeric,
    createdAt: ago(30),
  );
  final habits = [sport, study, smoke, pages];

  final power = MetricPresets.power('power');
  final money = MetricPresets.money('money');

  MetricReport calc(
    Metric metric,
    List<HabitMetricRule> rules,
    Map<String, Map<int, EntryValue>> marks,
  ) => MetricCalculator.calculate(
    metric: metric,
    rules: rules,
    habits: habits,
    histories: {
      for (final e in marks.entries)
        e.key: HabitHistory({
          for (final m in e.value.entries) ago(m.key): m.value,
        }),
    },
  );

  HabitMetricRule rule(
    String habit,
    String metric,
    double reward,
    double penalty,
  ) => HabitMetricRule(
    habitId: habit,
    metricId: metric,
    reward: reward,
    penalty: penalty,
  );

  const done = EntryDone();
  const failed = EntryFailed();

  group('пропорциональный режим (Power)', () {
    final rules = [
      rule('sport', 'power', 2, 10),
      rule('study', 'power', 3, 20),
      rule('smoke', 'power', 5, 50),
    ];

    test('прирост = лимит × очки / максимум возможных', () {
      // Выполнено 2 + 3 из 10 возможных → 1% × 0.5.
      final report = calc(power, rules, {
        'sport': {0: done},
        'study': {0: done},
      });
      expect(report.days.single.points, 5);
      expect(report.days.single.maxPoints, 10);
      expect(report.days.single.gain, closeTo(0.5, 1e-9));
      expect(report.currentValue, closeTo(0.5, 1e-9));
    });

    test('всё выполнено — ровно лимит в день (+1%)', () {
      final report = calc(power, rules, {
        'sport': {0: done, 1: done},
        'study': {0: done, 1: done},
        'smoke': {0: done, 1: done},
      });
      expect(report.days.map((d) => d.gain), [1, 1]);
      expect(report.currentValue, 2);
    });

    test('пропуск (0) исключается из максимума и ни на что не влияет', () {
      final report = calc(power, rules, {
        'sport': {0: done},
        'study': {0: const EntrySkipped()},
        'smoke': {0: done},
      });
      // 7 из 7 (учёба не учитывается) → полный прирост.
      expect(report.days.single.maxPoints, 7);
      expect(report.days.single.gain, 1);
    });

    test('потеря = MIN(лимит потери, сумма штрафов)', () {
      final report = calc(power, rules, {
        'smoke': {0: failed},
        'study': {0: failed},
        'sport': {0: failed},
      });
      // Штрафы 10 + 20 + 50 = 80, лимит 50.
      expect(report.days.single.penalties, 80);
      expect(report.days.single.loss, 50);
      expect(report.currentValue, -50); // метрика может уйти в минус
    });

    test('прирост и потеря в один день считаются вместе', () {
      final report = calc(power, rules, {
        'sport': {0: done},
        'study': {0: done},
        'smoke': {0: failed},
      });
      final day = report.days.single;
      expect(day.gain, closeTo(0.5, 1e-9));
      expect(day.loss, 50);
      expect(day.net, closeTo(-49.5, 1e-9));
    });
  });

  group('абсолютный режим (Money)', () {
    final rules = [
      rule('sport', 'money', 200000, 300000),
      rule('study', 'money', 150000, 900000),
      rule('pages', 'money', 1000, 0),
    ];

    test('прирост = MIN(лимит, сумма наград)', () {
      final report = calc(money, rules, {
        'sport': {0: done, 1: done},
        'study': {0: done},
      });
      // День 1: 200 000; день 0: 350 000 → лимит 300 000.
      expect(report.days.map((d) => d.gain), [200000, 300000]);
      expect(report.currentValue, 500000);
    });

    test('лимит потери в день', () {
      final report = calc(money, rules, {
        'sport': {0: failed},
        'study': {0: failed},
      });
      expect(report.days.single.loss, 1000000);
    });

    test('числовая привычка: число > 0 даёт награду, 0 — нет', () {
      final report = calc(money, rules, {
        'pages': {2: const EntryAmount(25), 1: const EntryAmount(0)},
      });
      expect(report.days.map((d) => d.gain), [1000, 0]);
    });

    test('стартовое значение учитывается', () {
      final start = money.copyWith(startValue: 5000);
      final report = calc(start, rules, {
        'sport': {0: done},
      });
      expect(report.currentValue, 205000);
    });
  });

  test('пустые дни не создают записей и не меняют метрику', () {
    final report = calc(
      money,
      [rule('sport', 'money', 100, 100)],
      {
        'sport': {5: done, 1: done},
      },
    );
    expect(report.days.map((d) => d.date), [ago(5), ago(1)]);
    expect(report.netOn(ago(3)), 0);
    expect(report.netOn(ago(1)), 100);
  });

  test('привычка без связей на метрику не влияет', () {
    final report = calc(
      money,
      [rule('sport', 'money', 100, 100)],
      {
        'study': {0: done, 1: failed},
      },
    );
    expect(report.days, isEmpty);
    expect(report.currentValue, 0);
  });

  test('одна привычка может влиять на несколько метрик', () {
    final rules = [
      rule('sport', 'money', 100, 0),
      rule('sport', 'power', 1, 1),
    ];
    final marks = {
      'sport': {0: done},
    };
    expect(calc(money, rules, marks).currentValue, 100);
    expect(calc(power, rules, marks).currentValue, 1);
  });

  test('при изменении весов история пересчитывается', () {
    final marks = {
      'sport': {0: done, 1: done, 2: failed},
    };
    final before = calc(money, [rule('sport', 'money', 100, 50)], marks);
    final after = calc(money, [rule('sport', 'money', 300, 500)], marks);
    expect(before.currentValue, 150); // 100 + 100 − 50
    expect(after.currentValue, 100); // 300 + 300 − 500
  });

  test('пропорциональный режим: незапланированная привычка не в максимуме', () {
    final weekdaysOnly = Habit(
      id: 'gym',
      title: 'Зал',
      // 09.09.2026 — среда, привычка только по понедельникам.
      schedule: const HabitSchedule.weekdays({1}),
      createdAt: ago(30),
    );
    final report = MetricCalculator.calculate(
      metric: power,
      rules: [rule('sport', 'power', 1, 1), rule('gym', 'power', 1, 1)],
      habits: [sport, weekdaysOnly],
      histories: {
        'sport': HabitHistory({today: done}),
      },
    );
    expect(report.days.single.maxPoints, 1);
    expect(report.currentValue, 1);
  });
}
