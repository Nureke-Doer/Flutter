import 'package:flutter_test/flutter_test.dart';
import 'package:habit_study_tracker/data/datasources/local/hive_storage.dart';
import 'package:habit_study_tracker/data/repositories/hive_category_repository.dart';
import 'package:habit_study_tracker/data/repositories/hive_goal_repository.dart';
import 'package:habit_study_tracker/data/repositories/hive_habit_repository.dart';
import 'package:habit_study_tracker/domain/entities/category.dart';
import 'package:habit_study_tracker/domain/entities/habit.dart';
import 'package:habit_study_tracker/domain/entities/habit_entry.dart';
import 'package:habit_study_tracker/domain/entities/study_goal.dart';
import 'package:hive_ce/hive.dart';

import '../helpers/hive_test_utils.dart';

void main() {
  final day = DateTime(2026, 9, 9);
  late HiveHabitRepository repository;

  HiveHabitRepository create() => HiveHabitRepository(
    habits: testCollection(HiveBoxes.habits),
    entries: testCollection(HiveBoxes.entries),
  );

  setUp(() async {
    await setUpTestHive();
    repository = create();
  });

  tearDown(tearDownTestHive);

  test('сохраняет все поля привычки, обновляет и удаляет', () async {
    final habit = Habit(
      id: 'a',
      title: 'Английский',
      categoryId: 'cat_study',
      kind: HabitKind.numeric,
      unit: 'мин',
      target: 30,
      schedule: const HabitSchedule.weekdays({1, 3, 5}),
      createdAt: day,
      reminderMinutes: 600,
      placeId: 'library',
    );
    await repository.saveHabit(habit);
    expect(await repository.watchHabits().first, [habit]);

    final tpw = habit.copyWith(
      title: 'English',
      schedule: const HabitSchedule.timesPerWeek(4),
      archived: true,
    );
    await repository.saveHabit(tpw);
    expect((await repository.watchHabits().first).single, tpw);

    await repository.deleteHabit('a');
    expect(await repository.watchHabits().first, isEmpty);
  });

  test('отметки: запись, очистка, удаление вместе с привычкой', () async {
    await repository.saveHabit(Habit(id: 'a', title: 'A', createdAt: day));
    await repository.setEntry('a', day, const EntryAmount(12));
    await repository.setEntry(
      'a',
      day.add(const Duration(days: 1)),
      const EntryFailed(),
    );
    await repository.setEntry('b', day, const EntryDone());

    var entries = await repository.watchEntries().first;
    expect(entries, hasLength(3));
    expect(
      entries.firstWhere((e) => e.habitId == 'a' && e.date == day).value,
      const EntryAmount(12),
    );

    await repository.setEntry('a', day, null);
    entries = await repository.watchEntries().first;
    expect(entries, hasLength(2));

    await repository.deleteHabit('a');
    entries = await repository.watchEntries().first;
    expect(entries.single.habitId, 'b');

    await repository.restoreEntries([
      HabitEntry(habitId: 'a', date: day, value: const EntryDone()),
    ]);
    expect(await repository.watchEntries().first, hasLength(2));
  });

  test('данные сохраняются после перезапуска (закрытия коробок)', () async {
    await repository.saveHabit(Habit(id: 'x', title: 'X', createdAt: day));
    await repository.setEntry('x', day, const EntryDone());
    await Hive.close();
    await openHiveBoxes();

    final reopened = create();
    expect((await reopened.watchHabits().first).single.id, 'x');
    expect(
      (await reopened.watchEntries().first).single.value,
      const EntryDone(),
    );
  });

  test('watchHabits сообщает об изменениях', () async {
    final emitted = <int>[];
    final sub = repository.watchHabits().listen((l) => emitted.add(l.length));
    await Future<void>.delayed(Duration.zero);
    await repository.saveHabit(Habit(id: '1', title: '1', createdAt: day));
    await repository.saveHabit(Habit(id: '2', title: '2', createdAt: day));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(emitted, [0, 1, 2]);
    await sub.cancel();
  });

  test('категории: сортировка и переименование', () async {
    final categories = HiveCategoryRepository(
      testCollection(HiveBoxes.categories),
    );
    await categories.saveCategory(const Category(id: 'a', name: 'A'));
    await categories.saveCategory(
      const Category(id: 'b', name: 'B', sortOrder: 1),
    );
    await categories.saveCategory(
      const Category(id: 'c', name: 'C', sortOrder: 2),
    );
    await categories.reorder(['c', 'a', 'b']);
    var list = await categories.watchCategories().first;
    expect(list.map((c) => c.id), ['c', 'a', 'b']);

    await categories.saveCategory(list.first.copyWith(name: 'Спорт'));
    await categories.deleteCategory('a');
    list = await categories.watchCategories().first;
    expect(list.map((c) => c.name), ['Спорт', 'B']);
  });

  test('цели: сохранение и сортировка по дедлайну', () async {
    final goals = HiveGoalRepository(testCollection(HiveBoxes.goals));
    final later = StudyGoal(
      id: 'late',
      title: 'Поздняя',
      target: 10,
      deadline: DateTime(2026, 12, 1),
      createdAt: day,
      linkedHabitIds: const {'a', 'b'},
    );
    final soon = StudyGoal(
      id: 'soon',
      title: 'Скоро',
      target: 300,
      unit: 'стр.',
      deadline: DateTime(2026, 10, 1),
      createdAt: day,
      bookTitle: 'SICP',
      bookCoverId: 42,
    );
    await goals.saveGoal(later);
    await goals.saveGoal(soon);
    expect(await goals.watchGoals().first, [soon, later]);
    await goals.deleteGoal('soon');
    expect(await goals.watchGoals().first, [later]);
  });
}
