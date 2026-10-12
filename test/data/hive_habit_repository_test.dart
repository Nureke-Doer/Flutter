import 'package:flutter_test/flutter_test.dart';
import 'package:habit_study_tracker/data/datasources/local/hive_storage.dart';
import 'package:habit_study_tracker/data/repositories/hive_habit_repository.dart';
import 'package:habit_study_tracker/domain/entities/habit.dart';
import 'package:hive_ce/hive.dart';

import '../helpers/hive_test_utils.dart';

void main() {
  final day = DateTime(2026, 9, 9);
  late HiveHabitRepository repository;

  HiveHabitRepository create() => HiveHabitRepository(
    habitsBox: Hive.box<String>(HiveBoxes.habits),
    metaBox: Hive.box<String>(HiveBoxes.meta),
  );

  setUp(() async {
    await setUpTestHive();
    repository = create();
  });

  tearDown(tearDownTestHive);

  test('сохраняет, обновляет и удаляет цели', () async {
    final habit = Habit(
      id: 'a',
      title: 'Английский',
      type: HabitType.study,
      targetMinutes: 30,
      weekdays: const {1, 3, 5},
      createdAt: day,
      completedDays: {day},
      reminderMinutes: 600,
    );
    await repository.saveHabit(habit);
    expect(await repository.watchHabits().first, [habit]);

    await repository.saveHabit(habit.copyWith(title: 'English'));
    expect((await repository.watchHabits().first).single.title, 'English');

    await repository.deleteHabit('a');
    expect(await repository.watchHabits().first, isEmpty);
  });

  test('данные сохраняются после перезапуска (закрытия коробок)', () async {
    await repository.saveHabit(Habit(id: 'x', title: 'X', createdAt: day));
    await Hive.close();
    await openHiveBoxes();

    final reopened = create();
    final habits = await reopened.watchHabits().first;
    expect(habits.single.id, 'x');
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

  test('демо-данные добавляются только один раз', () async {
    await repository.seedIfNeeded();
    final seeded = await repository.watchHabits().first;
    expect(seeded, isNotEmpty);

    for (final h in seeded) {
      await repository.deleteHabit(h.id);
    }
    await repository.seedIfNeeded();
    expect(await repository.watchHabits().first, isEmpty);
  });

  test('повреждённая запись пропускается', () async {
    await Hive.box<String>(HiveBoxes.habits).put('bad', '{not json');
    await repository.saveHabit(Habit(id: 'ok', title: 'OK', createdAt: day));
    expect((await repository.watchHabits().first).single.id, 'ok');
  });
}
