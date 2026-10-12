import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_study_tracker/core/di/injection.dart';
import 'package:habit_study_tracker/core/theme/app_theme.dart';
import 'package:habit_study_tracker/data/repositories/in_memory_habit_repository.dart';
import 'package:habit_study_tracker/domain/entities/habit.dart';
import 'package:habit_study_tracker/domain/repositories/habit_repository.dart';
import 'package:habit_study_tracker/l10n/generated/app_localizations.dart';
import 'package:habit_study_tracker/domain/repositories/materials_repository.dart';
import 'package:habit_study_tracker/presentation/blocs/favorites/favorites_cubit.dart';
import 'package:habit_study_tracker/presentation/blocs/habits/habits_bloc.dart';
import 'package:habit_study_tracker/presentation/blocs/materials/materials_bloc.dart';
import 'package:habit_study_tracker/presentation/blocs/quote/quote_cubit.dart';
import 'package:habit_study_tracker/presentation/providers/settings_notifier.dart';
import 'package:provider/provider.dart';

import 'fakes.dart';

extension PumpApp on WidgetTester {
  /// Оборачивает виджет в MaterialApp с локализацией, темой,
  /// [HabitsBloc] (на репозитории в памяти), [QuoteCubit] и [SettingsNotifier].
  Future<void> pumpApp(
    Widget child, {
    List<Habit>? habits,
    HabitRepository? repository,
    SettingsNotifier? settings,
    MaterialsRepository? materials,
  }) {
    final repo =
        repository ?? InMemoryHabitRepository(initial: habits ?? const []);
    // Экран размером с типичный телефон (432×960 логических пикселей).
    view
      ..physicalSize = const Size(1080, 2400)
      ..devicePixelRatio = 2.5;
    addTearDown(view.reset);
    // Экран «Материалы» берёт свой BLoC из get_it.
    if (!getIt.isRegistered<MaterialsBloc>()) {
      getIt.registerFactory(
        () => MaterialsBloc(repository: materials ?? FakeMaterialsRepository()),
      );
    }
    return pumpWidget(
      MultiProvider(
        providers: [
          BlocProvider(
            create: (_) =>
                HabitsBloc(repository: repo)
                  ..add(const HabitsSubscriptionRequested()),
          ),
          BlocProvider(
            create: (_) =>
                QuoteCubit(repository: materials ?? FakeMaterialsRepository())
                  ..load(),
          ),
          BlocProvider(
            create: (_) =>
                FavoritesCubit(repository: FakeFavoritesRepository()),
          ),
          ChangeNotifierProvider.value(
            value: settings ?? SettingsNotifier(FakeSettingsRepository()),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('ru'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: child,
        ),
      ),
    );
  }
}
