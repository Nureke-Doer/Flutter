import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/breakpoints.dart';
import '../../l10n/generated/app_localizations.dart';

/// Оболочка с навигацией по вкладкам: Сегодня, Привычки, Статистика,
/// Цели, Профиль.
///
/// Адаптивная вёрстка:
/// - телефон в портрете (compact) — нижняя панель `NavigationBar`;
/// - альбомная ориентация / планшет (medium, expanded) — боковая
///   `NavigationRail`, на широком экране — с подписями.
class ScaffoldWithNavigation extends StatelessWidget {
  const ScaffoldWithNavigation({super.key, required this.navigationShell});

  /// Состояние вложенной навигации от `StatefulShellRoute`.
  final StatefulNavigationShell navigationShell;

  void _onSelect(int index) => navigationShell.goBranch(
    index,
    // Повторное нажатие на активную вкладку возвращает к её началу.
    initialLocation: index == navigationShell.currentIndex,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final destinations = [
      (Icons.today_outlined, Icons.today, l10n.navToday),
      (Icons.checklist_outlined, Icons.checklist, l10n.navHabits),
      (Icons.insights_outlined, Icons.insights, l10n.navStatistics),
      (Icons.flag_outlined, Icons.flag, l10n.navGoals),
      (Icons.person_outline, Icons.person, l10n.navProfile),
    ];
    final width = MediaQuery.sizeOf(context).width;

    if (Breakpoints.of(width) == WindowSize.compact) {
      return Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _onSelect,
          destinations: [
            for (final (icon, selected, label) in destinations)
              NavigationDestination(
                icon: Icon(icon),
                selectedIcon: Icon(selected),
                label: label,
              ),
          ],
        ),
      );
    }

    final extended = width >= Breakpoints.large;
    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            right: false,
            child: NavigationRail(
              key: const Key('navigationRail'),
              extended: extended,
              labelType: extended
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _onSelect,
              destinations: [
                for (final (icon, selected, label) in destinations)
                  NavigationRailDestination(
                    icon: Icon(icon),
                    selectedIcon: Icon(selected),
                    label: Text(label),
                  ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}
