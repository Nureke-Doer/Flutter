import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_study_tracker/core/di/injection.dart';
import 'package:habit_study_tracker/core/theme/app_theme.dart';
import 'package:habit_study_tracker/data/datasources/demo_habits.dart';
import 'package:habit_study_tracker/data/repositories/in_memory_habit_repository.dart';
import 'package:habit_study_tracker/domain/entities/category.dart';
import 'package:habit_study_tracker/domain/entities/habit.dart';
import 'package:habit_study_tracker/domain/entities/habit_entry.dart';
import 'package:habit_study_tracker/domain/entities/study_goal.dart';
import 'package:habit_study_tracker/domain/repositories/auth_repository.dart';
import 'package:habit_study_tracker/domain/repositories/habit_repository.dart';
import 'package:habit_study_tracker/domain/repositories/materials_repository.dart';
import 'package:habit_study_tracker/l10n/generated/app_localizations.dart';
import 'package:habit_study_tracker/presentation/blocs/auth/auth_cubit.dart';
import 'package:habit_study_tracker/presentation/blocs/categories/categories_cubit.dart';
import 'package:habit_study_tracker/presentation/blocs/favorites/favorites_cubit.dart';
import 'package:habit_study_tracker/presentation/blocs/goals/goals_cubit.dart';
import 'package:habit_study_tracker/presentation/blocs/habits/habits_bloc.dart';
import 'package:habit_study_tracker/presentation/blocs/materials/materials_bloc.dart';
import 'package:habit_study_tracker/presentation/blocs/quote/quote_cubit.dart';
import 'package:habit_study_tracker/presentation/providers/settings_notifier.dart';
import 'package:habit_study_tracker/presentation/router/app_router.dart';
import 'package:provider/provider.dart';

import 'fakes.dart';

/// Размеры экрана для тестов адаптивной вёрстки (логические пиксели).
abstract final class TestScreens {
  /// Телефон в портрете: 432×960.
  static const phone = Size(1080, 2400);

  /// Телефон в альбомной ориентации: 960×432.
  static const phoneLandscape = Size(2400, 1080);

  /// Планшет в альбомной ориентации: 1280×800.
  static const tablet = Size(3200, 2000);
}

extension PumpApp on WidgetTester {
  void _setScreen(Size physical) {
    view
      ..physicalSize = physical
      ..devicePixelRatio = 2.5;
    addTearDown(view.reset);
  }

  Widget _withProviders(
    Widget child, {
    required HabitRepository repository,
    required List<Category> categories,
    required List<StudyGoal> goals,
    required SettingsNotifier settings,
    required MaterialsRepository materials,
    required AuthRepository auth,
  }) {
    // Экран «Материалы» берёт свой BLoC из get_it.
    if (!getIt.isRegistered<MaterialsBloc>()) {
      getIt.registerFactory(() => MaterialsBloc(repository: materials));
    }
    return MultiProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit(repository: auth)),
        BlocProvider(
          create: (_) =>
              HabitsBloc(repository: repository)
                ..add(const HabitsSubscriptionRequested()),
        ),
        BlocProvider(
          create: (_) =>
              CategoriesCubit(repository: FakeCategoryRepository(categories)),
        ),
        BlocProvider(
          create: (_) => GoalsCubit(repository: FakeGoalRepository(goals)),
        ),
        BlocProvider(create: (_) => QuoteCubit(repository: materials)..load()),
        BlocProvider(
          create: (_) => FavoritesCubit(repository: FakeFavoritesRepository()),
        ),
        ChangeNotifierProvider.value(value: settings),
      ],
      child: child,
    );
  }

  static const _delegates = [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  /// Оборачивает виджет в MaterialApp с локализацией, темой и BLoC-ами
  /// (на репозиториях в памяти).
  Future<void> pumpApp(
    Widget child, {
    List<Habit>? habits,
    List<HabitEntry> entries = const [],
    List<Category>? categories,
    List<StudyGoal> goals = const [],
    HabitRepository? repository,
    SettingsNotifier? settings,
    MaterialsRepository? materials,
    Size screen = TestScreens.phone,
  }) {
    _setScreen(screen);
    return pumpWidget(
      _withProviders(
        MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('ru'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: _delegates,
          home: child,
        ),
        repository:
            repository ??
            InMemoryHabitRepository(
              initial: habits ?? const [],
              entries: entries,
            ),
        categories: categories ?? buildDemoData().categories,
        goals: goals,
        settings: settings ?? SettingsNotifier(FakeSettingsRepository()),
        materials: materials ?? FakeMaterialsRepository(),
        auth: FakeAuthRepository(),
      ),
    );
  }

  /// Полное приложение с GoRouter: навигация, redirect, вкладки.
  /// Возвращает роутер, чтобы тест мог проверить текущий адрес.
  Future<GoRouter> pumpRouterApp({
    String initialLocation = '/today',
    List<Habit>? habits,
    List<HabitEntry> entries = const [],
    List<Category>? categories,
    List<StudyGoal> goals = const [],
    AuthRepository? auth,
    SettingsNotifier? settings,
    Size screen = TestScreens.phone,
  }) async {
    _setScreen(screen);
    final authRepository = auth ?? FakeAuthRepository();
    final router = createRouter(
      auth: authRepository,
      initialLocation: initialLocation,
    );
    addTearDown(router.dispose);
    await pumpWidget(
      _withProviders(
        MaterialApp.router(
          theme: AppTheme.light(),
          locale: const Locale('ru'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: _delegates,
          routerConfig: router,
        ),
        repository: InMemoryHabitRepository(
          initial: habits ?? const [],
          entries: entries,
        ),
        categories: categories ?? buildDemoData().categories,
        goals: goals,
        settings: settings ?? SettingsNotifier(FakeSettingsRepository()),
        materials: FakeMaterialsRepository(),
        auth: authRepository,
      ),
    );
    await pumpAndSettle();
    return router;
  }
}

/// Адрес верхнего (видимого) экрана, например `/habit/a`.
/// `router.state` учитывает и экраны, открытые через `push`.
String locationOf(GoRouter router) => router.state.uri.toString();
