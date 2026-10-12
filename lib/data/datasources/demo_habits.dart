import '../../core/utils/date_utils.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_entry.dart';
import '../../domain/entities/study_goal.dart';

/// Демонстрационные данные для первого запуска.
///
/// Это не «зашитые» привычки: они записываются в хранилище один раз,
/// и пользователь может их изменить или удалить. Даты отметок
/// генерируются относительно сегодняшнего дня, чтобы серии
/// и статистика выглядели «живыми».
class DemoData {
  DemoData({
    required this.categories,
    required this.habits,
    required this.entries,
    required this.goals,
  });

  final List<Category> categories;
  final List<Habit> habits;
  final List<HabitEntry> entries;
  final List<StudyGoal> goals;
}

DemoData buildDemoData([DateTime? now]) {
  final today = dateOnly(now ?? DateTime.now());
  DateTime ago(int days) => addDays(today, -days);

  const study = Category(
    id: 'cat_study',
    name: 'Учёба',
    colorValue: 0xFF8E24AA,
  );
  const sport = Category(
    id: 'cat_sport',
    name: 'Спорт',
    sortOrder: 1,
    colorValue: 0xFFE53935,
  );
  const health = Category(
    id: 'cat_health',
    name: 'Здоровье',
    sortOrder: 2,
    colorValue: 0xFF1E88E5,
  );
  const quit = Category(
    id: 'cat_quit',
    name: 'Зависимости',
    sortOrder: 3,
    colorValue: 0xFF6D4C41,
  );

  final habits = buildDemoHabits(today);

  final entries = <HabitEntry>[];
  void mark(String id, Iterable<int> daysAgo, EntryValue value) {
    for (final d in daysAgo) {
      entries.add(HabitEntry(habitId: id, date: ago(d), value: value));
    }
  }

  void amounts(String id, Map<int, double> values) =>
      values.forEach((d, v) => mark(id, [d], EntryAmount(v)));

  amounts('water', {
    for (final d in [0, 1, 2, 3, 4, 5, 7, 8, 9, 12, 13, 14, 15, 16]) d: 8,
  });
  amounts('water', {6: 5, 10: 3});
  mark('workout', [1, 2, 3, 6, 7, 8, 9, 10, 14, 15], const EntryDone());
  mark('workout', [4], const EntryFailed());
  mark('workout', [5], const EntrySkipped());
  amounts('english', {
    for (final d in [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]) d: 30,
  });
  amounts('english', {13: 45, 20: 20, 21: 25});
  mark('english', [12], const EntryFailed());
  mark('algorithms', [2, 4, 6, 9, 11], const EntryDone());
  amounts('reading', {1: 25, 2: 20, 4: 32, 5: 18, 6: 40});
  mark('no_social', [0, 1, 2, 3, 4, 5, 6, 8, 9, 10], const EntryDone());
  mark('no_social', [7], const EntryFailed());

  return DemoData(
    categories: const [study, sport, health, quit],
    habits: habits,
    entries: entries,
    goals: [
      StudyGoal(
        id: 'goal_reading',
        title: 'Прочитать 300 страниц',
        description: 'Книга по алгоритмам до конца семестра',
        target: 300,
        unit: 'стр.',
        deadline: addDays(today, 30),
        linkedHabitIds: const {'reading'},
        manualProgress: 40,
        createdAt: ago(7),
      ),
      StudyGoal(
        id: 'goal_ielts',
        title: 'Подготовка к IELTS',
        target: 1500,
        unit: 'мин',
        deadline: addDays(today, 60),
        linkedHabitIds: const {'english'},
        createdAt: ago(21),
      ),
    ],
  );
}

/// Только привычки (без отметок) — удобно для тестов.
List<Habit> buildDemoHabits([DateTime? now]) {
  final today = dateOnly(now ?? DateTime.now());
  DateTime ago(int days) => addDays(today, -days);
  return [
    Habit(
      id: 'water',
      title: 'Выпить воды',
      categoryId: 'cat_health',
      kind: HabitKind.numeric,
      unit: 'стак.',
      target: 8,
      icon: HabitIcon.water,
      colorValue: 0xFF1E88E5,
      createdAt: ago(30),
      reminderMinutes: 9 * 60,
    ),
    Habit(
      id: 'workout',
      title: 'Утренняя зарядка',
      description: '15 минут упражнений после пробуждения',
      categoryId: 'cat_sport',
      icon: HabitIcon.run,
      colorValue: 0xFFE53935,
      schedule: const HabitSchedule.weekdays({1, 2, 3, 4, 5}),
      createdAt: ago(21),
      reminderMinutes: 7 * 60 + 30,
    ),
    Habit(
      id: 'english',
      title: 'Английский язык',
      description: 'Слова в Anki + один подкаст',
      categoryId: 'cat_study',
      kind: HabitKind.numeric,
      unit: 'мин',
      target: 30,
      icon: HabitIcon.language,
      colorValue: 0xFF8E24AA,
      createdAt: ago(40),
      reminderMinutes: 19 * 60,
    ),
    Habit(
      id: 'algorithms',
      title: 'Решить 2 задачи по алгоритмам',
      categoryId: 'cat_study',
      icon: HabitIcon.code,
      colorValue: 0xFF43A047,
      schedule: const HabitSchedule.timesPerWeek(3),
      createdAt: ago(14),
    ),
    Habit(
      id: 'reading',
      title: 'Чтение',
      categoryId: 'cat_study',
      kind: HabitKind.numeric,
      unit: 'стр.',
      target: 20,
      icon: HabitIcon.book,
      colorValue: 0xFFFB8C00,
      createdAt: ago(10),
    ),
    Habit(
      id: 'no_social',
      title: 'Без соцсетей до обеда',
      categoryId: 'cat_quit',
      kind: HabitKind.quit,
      icon: HabitIcon.phone,
      colorValue: 0xFF6D4C41,
      createdAt: ago(12),
    ),
  ];
}
