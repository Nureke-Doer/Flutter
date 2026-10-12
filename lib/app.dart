import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'l10n/generated/app_localizations.dart';
import 'presentation/blocs/categories/categories_cubit.dart';
import 'presentation/blocs/favorites/favorites_cubit.dart';
import 'presentation/blocs/goals/goals_cubit.dart';
import 'presentation/blocs/habits/habits_bloc.dart';
import 'presentation/blocs/quote/quote_cubit.dart';
import 'presentation/providers/settings_notifier.dart';
import 'presentation/screens/home_shell.dart';

class HabitStudyTrackerApp extends StatelessWidget {
  const HabitStudyTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Зависимости берутся из get_it и «раздаются» дереву виджетов:
    // BLoC — через BlocProvider, настройки — через ChangeNotifierProvider.
    return MultiProvider(
      providers: [
        BlocProvider<HabitsBloc>(
          create: (_) =>
              getIt<HabitsBloc>()..add(const HabitsSubscriptionRequested()),
        ),
        BlocProvider<CategoriesCubit>(create: (_) => getIt<CategoriesCubit>()),
        BlocProvider<GoalsCubit>(create: (_) => getIt<GoalsCubit>()),
        BlocProvider<QuoteCubit>(create: (_) => getIt<QuoteCubit>()..load()),
        BlocProvider<FavoritesCubit>(create: (_) => getIt<FavoritesCubit>()),
        ChangeNotifierProvider<SettingsNotifier>.value(
          value: getIt<SettingsNotifier>(),
        ),
      ],
      child: Consumer<SettingsNotifier>(
        builder: (context, settings, _) => MaterialApp(
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
          home: const HomeShell(),
        ),
      ),
    );
  }
}
