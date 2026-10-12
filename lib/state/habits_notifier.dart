import 'package:flutter/foundation.dart';

import '../data/mock_habits.dart';
import '../models/habit.dart';

/// Неделя 3, шаг 3 — **Provider**.
///
/// Вся логика работы со списком целей вынесена в отдельный класс
/// `ChangeNotifier`. Он не зависит от виджетов, поэтому его легко
/// тестировать обычными unit-тестами. После каждого изменения
/// вызывается [notifyListeners], и подписанные виджеты перестраиваются.
class HabitsNotifier extends ChangeNotifier {
  HabitsNotifier({List<Habit>? initialHabits})
    : _habits = initialHabits ?? buildMockHabits();

  List<Habit> _habits;

  List<Habit> get habits => List.unmodifiable(_habits);

  Habit? byId(String id) {
    for (final h in _habits) {
      if (h.id == id) return h;
    }
    return null;
  }

  void toggle(String id, DateTime day) {
    _habits = [for (final h in _habits) h.id == id ? h.toggleDay(day) : h];
    notifyListeners();
  }

  void save(Habit habit) {
    final exists = _habits.any((h) => h.id == habit.id);
    _habits = exists
        ? [for (final h in _habits) h.id == habit.id ? habit : h]
        : [..._habits, habit];
    notifyListeners();
  }

  void delete(String id) {
    _habits = _habits.where((h) => h.id != id).toList();
    notifyListeners();
  }
}
