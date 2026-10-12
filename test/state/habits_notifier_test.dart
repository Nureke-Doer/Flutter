import 'package:flutter_test/flutter_test.dart';
import 'package:habit_study_tracker/models/habit.dart';
import 'package:habit_study_tracker/state/habits_notifier.dart';

void main() {
  final day = DateTime(2026, 9, 9);
  Habit habit(String id) => Habit(id: id, title: id, createdAt: day);

  late HabitsNotifier notifier;
  late int notifications;

  setUp(() {
    notifier = HabitsNotifier(initialHabits: [habit('a'), habit('b')]);
    notifications = 0;
    notifier.addListener(() => notifications++);
  });

  test('toggle отмечает и снимает отметку', () {
    notifier.toggle('a', day);
    expect(notifier.byId('a')!.isCompletedOn(day), isTrue);
    notifier.toggle('a', day);
    expect(notifier.byId('a')!.isCompletedOn(day), isFalse);
    expect(notifications, 2);
  });

  test('save добавляет новую и обновляет существующую цель', () {
    notifier.save(habit('c'));
    expect(notifier.habits.length, 3);

    notifier.save(habit('a').copyWith(title: 'Новое название'));
    expect(notifier.habits.length, 3);
    expect(notifier.byId('a')!.title, 'Новое название');
    expect(notifications, 2);
  });

  test('delete удаляет цель', () {
    notifier.delete('b');
    expect(notifier.byId('b'), isNull);
    expect(notifier.habits.map((h) => h.id), ['a']);
    expect(notifications, 1);
  });

  test('habits нельзя изменить снаружи', () {
    expect(() => notifier.habits.add(habit('x')), throwsUnsupportedError);
  });
}
