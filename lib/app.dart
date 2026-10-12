import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'l10n/generated/app_localizations.dart';
import 'screens/home_shell.dart';
import 'state/habits_notifier.dart';
import 'theme/app_theme.dart';

class HabitStudyTrackerApp extends StatelessWidget {
  const HabitStudyTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Провайдер стоит выше MaterialApp, чтобы данные были доступны
    // на всех экранах, открытых через Navigator.
    return ChangeNotifierProvider(
      create: (_) => HabitsNotifier(),
      child: MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        locale: const Locale('ru'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const HomeShell(),
      ),
    );
  }
}
