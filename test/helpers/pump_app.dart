import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_study_tracker/l10n/generated/app_localizations.dart';
import 'package:habit_study_tracker/theme/app_theme.dart';

extension PumpApp on WidgetTester {
  /// Оборачивает виджет в MaterialApp с локализацией и темой.
  Future<void> pumpApp(Widget child) {
    return pumpWidget(
      MaterialApp(
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
    );
  }
}
