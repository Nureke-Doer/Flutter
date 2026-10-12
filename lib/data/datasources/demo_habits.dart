import '../../core/utils/date_utils.dart';
import '../../domain/entities/habit.dart';

/// Демонстрационные данные для первого запуска.
/// Даты выполнения генерируются относительно сегодняшнего дня,
/// чтобы серии и статистика выглядели «живыми».
List<Habit> buildDemoHabits([DateTime? now]) {
  final today = dateOnly(now ?? DateTime.now());

  Set<DateTime> daysAgo(Iterable<int> offsets) =>
      offsets.map((o) => addDays(today, -o)).toSet();

  return [
    Habit(
      id: 'water',
      title: 'Выпить 8 стаканов воды',
      icon: HabitIcon.water,
      colorValue: 0xFF1E88E5,
      createdAt: addDays(today, -30),
      reminderMinutes: 9 * 60,
      completedDays: daysAgo([
        0,
        1,
        2,
        3,
        4,
        5,
        7,
        8,
        9,
        12,
        13,
        14,
        15,
        16,
        17,
        18,
      ]),
    ),
    Habit(
      id: 'workout',
      title: 'Утренняя зарядка',
      description: '15 минут упражнений после пробуждения',
      icon: HabitIcon.run,
      colorValue: 0xFFE53935,
      weekdays: const {1, 2, 3, 4, 5},
      createdAt: addDays(today, -21),
      reminderMinutes: 7 * 60 + 30,
      completedDays: daysAgo([1, 2, 3, 6, 7, 8, 9, 10, 14, 15]),
    ),
    Habit(
      id: 'english',
      title: 'Английский язык',
      description: 'Слова в Anki + один подкаст',
      type: HabitType.study,
      icon: HabitIcon.language,
      colorValue: 0xFF8E24AA,
      targetMinutes: 30,
      createdAt: addDays(today, -40),
      reminderMinutes: 19 * 60,
      completedDays: daysAgo([
        0,
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        10,
        11,
        20,
        21,
        22,
      ]),
    ),
    Habit(
      id: 'algorithms',
      title: 'Решить 2 задачи по алгоритмам',
      type: HabitType.study,
      icon: HabitIcon.code,
      colorValue: 0xFF43A047,
      targetMinutes: 45,
      weekdays: const {1, 3, 5, 6},
      createdAt: addDays(today, -14),
      completedDays: daysAgo([2, 4, 6, 9, 11]),
    ),
    Habit(
      id: 'reading',
      title: 'Читать 20 страниц',
      icon: HabitIcon.book,
      colorValue: 0xFFFB8C00,
      createdAt: addDays(today, -10),
      completedDays: daysAgo([1, 2, 4, 5]),
    ),
  ];
}
