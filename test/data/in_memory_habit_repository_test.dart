import 'package:flutter_test/flutter_test.dart';
import 'package:habit_study_tracker/data/repositories/in_memory_habit_repository.dart';
import 'package:habit_study_tracker/domain/entities/habit.dart';

void main() {
  final day = DateTime(2026, 9, 9);
  Habit habit(String id, [String? title]) =>
      Habit(id: id, title: title ?? id, createdAt: day);

  test('watchHabits сразу отдаёт текущий список и затем изменения', () async {
    final repo = InMemoryHabitRepository(initial: [habit('a')]);
    final emitted = <List<String>>[];
    final sub = repo.watchHabits().listen(
      (list) => emitted.add(list.map((h) => h.id).toList()),
    );
    await Future<void>.delayed(Duration.zero);

    await repo.saveHabit(habit('b'));
    await repo.saveHabit(habit('a', 'A2'));
    await repo.deleteHabit('b');
    await Future<void>.delayed(Duration.zero);

    expect(emitted, [
      ['a'],
      ['a', 'b'],
      ['a', 'b'],
      ['a'],
    ]);
    await sub.cancel();
    await repo.dispose();
  });
}
