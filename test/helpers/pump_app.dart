import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_study_tracker/core/theme/app_theme.dart';
import 'package:habit_study_tracker/data/repositories/in_memory_habit_repository.dart';
import 'package:habit_study_tracker/domain/entities/habit.dart';
import 'package:habit_study_tracker/domain/repositories/habit_repository.dart';
import 'package:habit_study_tracker/l10n/generated/app_localizations.dart';
import 'package:habit_study_tracker/presentation/blocs/habits/habits_bloc.dart';
import 'package:habit_study_tracker/presentation/providers/settings_notifier.dart';
import 'package:provider/provider.dart';

extension PumpApp on WidgetTester {
  /// Оборачивает виджет в MaterialApp с локализацией, темой,
  /// [HabitsBloc] (на репозитории в памяти) и [SettingsNotifier].
  Future<void> pumpApp(
    Widget child, {
    List<Habit>? habits,
    HabitRepository? repository,
    SettingsNotifier? settings,
  }) {
    final repo =
        repository ?? InMemoryHabitRepository(initial: habits ?? const []);
    return pumpWidget(
      MultiProvider(
        providers: [
          BlocProvider(
            create: (_) =>
                HabitsBloc(repository: repo)
                  ..add(const HabitsSubscriptionRequested()),
          ),
          ChangeNotifierProvider.value(value: settings ?? SettingsNotifier()),
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
