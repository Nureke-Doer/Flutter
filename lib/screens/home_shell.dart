import 'package:flutter/material.dart';

import '../data/mock_habits.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/habit.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';
import 'today_screen.dart';

/// Корневой экран с нижней навигацией.
/// `StatefulWidget`, потому что хранит индекс выбранной вкладки.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  final List<Habit> _habits = buildMockHabits();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      // IndexedStack сохраняет состояние вкладок при переключении.
      body: IndexedStack(
        index: _index,
        children: [
          TodayScreen(habits: _habits),
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
