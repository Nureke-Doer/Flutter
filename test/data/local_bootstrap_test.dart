import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:habit_study_tracker/data/datasources/local/hive_storage.dart';
import 'package:habit_study_tracker/data/datasources/local/local_bootstrap.dart';
import 'package:habit_study_tracker/data/repositories/hive_habit_repository.dart';
import 'package:habit_study_tracker/domain/entities/habit.dart';
import 'package:habit_study_tracker/domain/entities/habit_entry.dart';
import 'package:hive_ce/hive.dart';

import '../helpers/hive_test_utils.dart';

void main() {
  setUp(setUpTestHive);
  tearDown(tearDownTestHive);

  LocalBootstrap bootstrap() => LocalBootstrap(
    habits: testCollection(HiveBoxes.habits),
    entries: testCollection(HiveBoxes.entries),
    categories: testCollection(HiveBoxes.categories),
    goals: testCollection(HiveBoxes.goals),
    meta: hiveBox(HiveBoxes.meta),
  );

  HiveHabitRepository repository() => HiveHabitRepository(
    habits: testCollection(HiveBoxes.habits),
    entries: testCollection(HiveBoxes.entries),
  );

  test('демо-данные добавляются только один раз', () async {
    await bootstrap().run();
    final seeded = await repository().watchHabits().first;
    expect(seeded, isNotEmpty);
    expect(testCollection(HiveBoxes.categories).readAll(), isNotEmpty);
    expect(testCollection(HiveBoxes.goals).readAll(), isNotEmpty);
    expect(await repository().watchEntries().first, isNotEmpty);

    for (final h in seeded) {
      await repository().deleteHabit(h.id);
    }
    await bootstrap().run();
    expect(await repository().watchHabits().first, isEmpty);
  });

  test('миграция привычек недель 4–6 в новый формат', () async {
    final legacy = await Hive.openBox<String>(HiveBoxes.legacyHabits);
    await legacy.put(
      'english',
      jsonEncode({
        'id': 'english',
        'title': 'Английский',
        'description': '',
        'type': 'study',
        'icon': 'language',
        'colorValue': 0xFF8E24AA,
        'weekdays': [1, 2, 3, 4, 5, 6, 7],
        'targetMinutes': 30,
        'completedDays': ['2026-09-07', '2026-09-08'],
        'createdAt': '2026-09-01T10:00:00.000',
      }),
    );
    await legacy.put(
      'run',
      jsonEncode({
        'id': 'run',
        'title': 'Бег',
        'type': 'habit',
        'icon': 'run',
        'colorValue': 0xFFE53935,
        'weekdays': [1, 3, 5],
        'completedDays': ['2026-09-07'],
        'createdAt': '2026-09-01T10:00:00.000',
      }),
    );
    await legacy.put('broken', '{not json');

    await bootstrap().run();

    final habits = await repository().watchHabits().first;
    final english = habits.firstWhere((h) => h.id == 'english');
    expect(english.kind, HabitKind.numeric);
    expect(english.unit, 'мин');
    expect(english.target, 30);
    expect(english.categoryId, 'cat_study');
    expect(english.schedule, const HabitSchedule.daily());
    final run = habits.firstWhere((h) => h.id == 'run');
    expect(run.kind, HabitKind.positive);
    expect(run.schedule, const HabitSchedule.weekdays({1, 3, 5}));

    final entries = await repository().watchEntries().first;
    expect(entries, hasLength(3));
    expect(
      entries.where((e) => e.habitId == 'english').map((e) => e.value),
      everyElement(const EntryAmount(30)),
    );
    // Демо-данные мигрировавшему пользователю не добавляются.
    expect(habits, hasLength(2));
    expect(await Hive.boxExists(HiveBoxes.legacyHabits), isFalse);
  });
}
