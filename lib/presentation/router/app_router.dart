import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/book.dart';
import '../../domain/repositories/auth_repository.dart';
import '../blocs/goals/goals_cubit.dart';
import '../blocs/habits/habits_bloc.dart';
import '../screens/book_details_screen.dart';
import '../screens/categories_screen.dart';
import '../screens/goal_detail_screen.dart';
import '../screens/goal_edit_screen.dart';
import '../screens/goals_screen.dart';
import '../screens/habit_detail_screen.dart';
import '../screens/habit_edit_screen.dart';
import '../screens/habits_screen.dart';
import '../screens/login_screen.dart';
import '../screens/materials_screen.dart';
import '../screens/not_found_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/scaffold_with_navigation.dart';
import '../screens/settings_screen.dart';
import '../screens/statistics_screen.dart';
import '../screens/today_screen.dart';
import 'router_refresh.dart';

/// Имена маршрутов. Переходы делаются по имени
/// (`context.pushNamed(AppRoutes.habit, pathParameters: {'id': id})`),
/// поэтому путь можно поменять в одном месте.
abstract final class AppRoutes {
  static const login = 'login';
  static const today = 'today';
  static const habits = 'habits';
  static const categories = 'categories';
  static const stats = 'stats';
  static const goals = 'goals';
  static const goal = 'goal';
  static const goalNew = 'goal-new';
  static const goalEdit = 'goal-edit';
  static const profile = 'profile';
  static const settings = 'settings';
  static const habit = 'habit';
  static const habitNew = 'habit-new';
  static const habitEdit = 'habit-edit';
  static const materials = 'materials';
  static const book = 'book';
}

/// Куда перенаправить пользователя (защита маршрутов по авторизации).
///
/// - не вошёл → на `/login`, запомнив исходный адрес в `?from=`;
/// - вошёл и находится на `/login` → туда, откуда пришёл (или «Сегодня»);
/// - иначе — без перенаправления (`null`).
///
/// Чистая функция — легко проверить unit-тестом.
String? authRedirect({required bool signedIn, required Uri uri}) {
  final onLogin = uri.path == '/login';
  if (!signedIn) {
    if (onLogin) return null;
    final from = uri.toString();
    return from == '/' || from == '/today'
        ? '/login'
        : Uri(path: '/login', queryParameters: {'from': from}).toString();
  }
  if (onLogin) return uri.queryParameters['from'] ?? '/today';
  return null;
}

GoRouter createRouter({
  required AuthRepository auth,
  String initialLocation = '/today',
}) {
  // Ключ корневого навигатора: маршруты с `parentNavigatorKey: rootKey`
  // открываются поверх нижней навигации (на весь экран).
  final rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: initialLocation,
    // При входе/выходе GoRouter заново вызывает redirect.
    refreshListenable: StreamRefreshListenable(auth.authStateChanges()),
    redirect: (context, state) =>
        authRedirect(signedIn: auth.currentUser != null, uri: state.uri),
    errorBuilder: (context, state) => NotFoundScreen(uri: state.uri),
    routes: [
      GoRoute(path: '/', redirect: (_, _) => '/today'),
      GoRoute(
        path: '/login',
        name: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      // Вложенная навигация: у каждой вкладки свой стек экранов,
      // который сохраняется при переключении вкладок (IndexedStack).
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) =>
            ScaffoldWithNavigation(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/today',
                name: AppRoutes.today,
                builder: (context, state) => const TodayScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/habits',
                name: AppRoutes.habits,
                builder: (context, state) => const HabitsScreen(),
                routes: [
                  GoRoute(
                    path: 'categories',
                    name: AppRoutes.categories,
                    builder: (context, state) => const CategoriesScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/stats',
                name: AppRoutes.stats,
                builder: (context, state) => const StatisticsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/goals',
                name: AppRoutes.goals,
                builder: (context, state) => const GoalsScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    name: AppRoutes.goalNew,
                    parentNavigatorKey: rootKey,
                    builder: (context, state) => const GoalEditScreen(),
                  ),
                  // Внутри вкладки: нижняя навигация остаётся видна.
                  GoRoute(
                    path: ':goalId',
                    name: AppRoutes.goal,
                    builder: (context, state) => GoalDetailScreen(
                      goalId: state.pathParameters['goalId']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        name: AppRoutes.goalEdit,
                        parentNavigatorKey: rootKey,
                        builder: (context, state) => GoalEditScreen(
                          initial: context.read<GoalsCubit>().byId(
                            state.pathParameters['goalId']!,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: AppRoutes.profile,
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'settings',
                    name: AppRoutes.settings,
                    builder: (context, state) => const SettingsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      // Экраны поверх нижней навигации.
      GoRoute(
        path: '/habit/new',
        name: AppRoutes.habitNew,
        builder: (context, state) => HabitEditScreen(
          initialCategoryId: state.uri.queryParameters['category'],
        ),
      ),
      GoRoute(
        path: '/habit/:id',
        name: AppRoutes.habit,
        builder: (context, state) =>
            HabitDetailScreen(habitId: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'edit',
            name: AppRoutes.habitEdit,
            builder: (context, state) => HabitEditScreen(
              initial: context.read<HabitsBloc>().state.byId(
                state.pathParameters['id']!,
              ),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/materials',
        name: AppRoutes.materials,
        builder: (context, state) =>
            MaterialsScreen(initialQuery: state.uri.queryParameters['q']),
        routes: [
          GoRoute(
            path: 'book',
            name: AppRoutes.book,
            // Книга передаётся объектом через `extra`. При открытии по
            // прямой ссылке объекта нет — возвращаем на поиск.
            redirect: (context, state) =>
                state.extra is Book ? null : '/materials',
            builder: (context, state) =>
                BookDetailsScreen(book: state.extra! as Book),
          ),
        ],
      ),
    ],
  );
}
