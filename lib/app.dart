import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'domain/repositories/auth_repository.dart';
import 'l10n/generated/app_localizations.dart';
import 'presentation/blocs/auth/auth_cubit.dart';
import 'presentation/blocs/categories/categories_cubit.dart';
import 'presentation/blocs/favorites/favorites_cubit.dart';
import 'presentation/blocs/goals/goals_cubit.dart';
import 'presentation/blocs/habits/habits_bloc.dart';
import 'presentation/blocs/metrics/metrics_cubit.dart';
import 'presentation/blocs/quote/quote_cubit.dart';
import 'presentation/providers/settings_notifier.dart';
import 'presentation/router/app_router.dart';

class HabitStudyTrackerApp extends StatefulWidget {
  const HabitStudyTrackerApp({super.key, this.router});

  /// Роутер создаётся в `main()`, чтобы уведомления могли открыть нужный
  /// экран. Если не передан (тесты) — создаётся здесь.
  final GoRouter? router;

  @override
  State<HabitStudyTrackerApp> createState() => _HabitStudyTrackerAppState();
}

class _HabitStudyTrackerAppState extends State<HabitStudyTrackerApp> {
  // Роутер создаётся один раз: при смене темы или языка MaterialApp
  // перестраивается, а стек экранов сохраняется.
  late final GoRouter _router =
      widget.router ?? createRouter(auth: getIt<AuthRepository>());

  @override
  void dispose() {
    if (widget.router == null) _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Зависимости берутся из get_it и «раздаются» дереву виджетов:
    // BLoC — через BlocProvider, настройки — через ChangeNotifierProvider.
    return MultiProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (_) => getIt<AuthCubit>()),
        BlocProvider<HabitsBloc>(
          create: (_) =>
              getIt<HabitsBloc>()..add(const HabitsSubscriptionRequested()),
        ),
        BlocProvider<CategoriesCubit>(create: (_) => getIt<CategoriesCubit>()),
        BlocProvider<GoalsCubit>(create: (_) => getIt<GoalsCubit>()),
        BlocProvider<MetricsCubit>(create: (_) => getIt<MetricsCubit>()),
        BlocProvider<QuoteCubit>(create: (_) => getIt<QuoteCubit>()..load()),
        BlocProvider<FavoritesCubit>(create: (_) => getIt<FavoritesCubit>()),
        ChangeNotifierProvider<SettingsNotifier>.value(
          value: getIt<SettingsNotifier>(),
        ),
      ],
      child: Consumer<SettingsNotifier>(
        builder: (context, settings, _) {
          // Язык для форматирования чисел и дат через intl (1 500 / 1,500).
          Intl.defaultLocale = settings.locale.languageCode;
          return MaterialApp.router(
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: settings.themeMode,
            locale: settings.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
