import 'package:flutter/widgets.dart';

import '../data/mock_habits.dart';
import '../models/habit.dart';

/// Неделя 3, шаг 2 — **InheritedWidget**.
///
/// `HabitsScope` хранит список целей в своём `State` и раздаёт его
/// всему поддереву через [_HabitsInherited]. Любой экран получает данные
/// и методы через `HabitsScope.of(context)` — без передачи колбэков
/// через конструкторы.
class HabitsScope extends StatefulWidget {
  const HabitsScope({super.key, required this.child, this.initialHabits});

  final Widget child;

  /// Начальные данные (удобно для тестов). По умолчанию — демо-данные.
  final List<Habit>? initialHabits;

  /// Возвращает состояние и подписывает [context] на изменения:
  /// при изменении списка виджет, вызвавший `of`, перестроится.
  static HabitsScopeState of(BuildContext context) {
    final inherited = context
        .dependOnInheritedWidgetOfExactType<_HabitsInherited>();
    assert(inherited != null, 'HabitsScope не найден в дереве виджетов');
    return inherited!.state;
  }

  /// Возвращает состояние **без подписки** на изменения.
  /// Используется в обработчиках нажатий, где перестраиваться не нужно.
  static HabitsScopeState read(BuildContext context) {
    final inherited = context.getInheritedWidgetOfExactType<_HabitsInherited>();
    assert(inherited != null, 'HabitsScope не найден в дереве виджетов');
    return inherited!.state;
  }

  @override
  State<HabitsScope> createState() => HabitsScopeState();
}

class HabitsScopeState extends State<HabitsScope> {
  late List<Habit> _habits = widget.initialHabits ?? buildMockHabits();

  List<Habit> get habits => List.unmodifiable(_habits);

  Habit? byId(String id) {
    for (final h in _habits) {
      if (h.id == id) return h;
    }
    return null;
  }

  void toggle(String id, DateTime day) {
    setState(() {
      _habits = [for (final h in _habits) h.id == id ? h.toggleDay(day) : h];
    });
  }

  void save(Habit habit) {
    setState(() {
      final exists = _habits.any((h) => h.id == habit.id);
      _habits = exists
          ? [for (final h in _habits) h.id == habit.id ? habit : h]
          : [..._habits, habit];
    });
  }

  void delete(String id) {
    setState(() => _habits = _habits.where((h) => h.id != id).toList());
  }

  @override
  Widget build(BuildContext context) {
    return _HabitsInherited(state: this, habits: _habits, child: widget.child);
  }
}

class _HabitsInherited extends InheritedWidget {
  const _HabitsInherited({
    required this.state,
    required this.habits,
    required super.child,
  });

  final HabitsScopeState state;

  /// Храним ссылку на список отдельно: при каждом изменении создаётся
  /// новый список, и [updateShouldNotify] это замечает.
  final List<Habit> habits;

  @override
  bool updateShouldNotify(_HabitsInherited oldWidget) =>
      !identical(habits, oldWidget.habits);
}
