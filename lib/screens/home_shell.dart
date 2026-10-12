import 'package:flutter/material.dart';

import '../data/mock_habits.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/habit.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';
import 'today_screen.dart';

/// Корневой экран с нижней навигацией.
///
/// Неделя 3, шаг 1 — **setState**. Список целей хранится прямо здесь,
/// а изменять его дочерние экраны могут только через колбэки,
/// которые приходится передавать вниз по дереву («prop drilling»).
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  List<Habit> _habits = buildMockHabits();

  void _toggle(Habit habit, DateTime day) {
    setState(() {
      _habits = [
        for (final h in _habits) h.id == habit.id ? h.toggleDay(day) : h,
      ];
    });
  }

  void _save(Habit habit) {
    setState(() {
      final exists = _habits.any((h) => h.id == habit.id);
      _habits = exists
          ? [for (final h in _habits) h.id == habit.id ? habit : h]
          : [..._habits, habit];
    });
  }

  void _delete(Habit habit) {
    setState(() => _habits = _habits.where((h) => h.id != habit.id).toList());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          TodayScreen(
            habits: _habits,
            onToggle: _toggle,
            onSave: _save,
            onDelete: _delete,
          ),
          StatisticsScreen(habits: _habits),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.today_outlined),
            selectedIcon: const Icon(Icons.today),
            label: l10n.navToday,
          ),
          NavigationDestination(
            icon: const Icon(Icons.insights_outlined),
            selectedIcon: const Icon(Icons.insights),
            label: l10n.navStatistics,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}
