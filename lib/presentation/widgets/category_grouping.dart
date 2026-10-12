import '../../domain/entities/category.dart';
import '../../domain/entities/habit.dart';

/// Группа привычек одной категории (`category == null` — «Без категории»).
class HabitGroup {
  const HabitGroup(this.category, this.habits);

  final Category? category;
  final List<Habit> habits;
}

/// Раскладывает привычки по категориям в порядке сортировки категорий.
/// Привычки без категории (или с удалённой категорией) — в конце.
List<HabitGroup> groupByCategory(
  List<Habit> habits,
  List<Category> categories,
) {
  final known = {for (final c in categories) c.id};
  final groups = <HabitGroup>[
    for (final c in categories)
      HabitGroup(c, habits.where((h) => h.categoryId == c.id).toList()),
    HabitGroup(
      null,
      habits.where((h) => !known.contains(h.categoryId)).toList(),
    ),
  ];
  return groups.where((g) => g.habits.isNotEmpty).toList();
}
