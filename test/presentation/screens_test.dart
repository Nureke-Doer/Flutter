import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_study_tracker/data/datasources/demo_habits.dart';
import 'package:habit_study_tracker/presentation/screens/habit_edit_screen.dart';
import 'package:habit_study_tracker/presentation/providers/settings_notifier.dart';
import 'package:habit_study_tracker/presentation/screens/settings_screen.dart';
import 'package:habit_study_tracker/presentation/screens/statistics_screen.dart';
import 'package:habit_study_tracker/presentation/screens/today_screen.dart';

import '../helpers/fakes.dart';
import '../helpers/pump_app.dart';

void main() {
  testWidgets('Экран «Сегодня» показывает цели и прогресс', (tester) async {
    await tester.pumpApp(const TodayScreen(), habits: buildDemoHabits());
    await tester.pumpAndSettle();

    expect(find.text('Сегодня'), findsOneWidget);
    expect(find.text('Английский язык'), findsOneWidget);
    expect(find.textContaining('Выполнено'), findsOneWidget);
  });

  testWidgets('Пустой список показывает подсказку', (tester) async {
    await tester.pumpApp(const TodayScreen(), habits: const []);
    await tester.pumpAndSettle();
    expect(find.text('На сегодня ничего не запланировано'), findsOneWidget);
  });

  testWidgets('Форма не сохраняется без названия', (tester) async {
    await tester.pumpApp(const HabitEditScreen());
    await tester.scrollUntilVisible(
      find.byKey(const Key('saveButton')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('saveButton')));
    await tester.pump();
    expect(find.text('Введите название'), findsOneWidget);
  });

  testWidgets('Настройки переключают тему и язык', (tester) async {
    final settings = SettingsNotifier(FakeSettingsRepository());
    await tester.pumpApp(const SettingsScreen(), settings: settings);

    await tester.tap(find.text('Тёмная'));
    await tester.pump();
    expect(settings.themeMode, ThemeMode.dark);

    await tester.tap(find.text('English'));
    await tester.pump();
    expect(settings.locale, const Locale('en'));
  });

  testWidgets('Статистика показывает пустое состояние без целей', (
    tester,
  ) async {
    await tester.pumpApp(const StatisticsScreen(), habits: const []);
    await tester.pumpAndSettle();
    expect(find.text('Добавь цели, чтобы увидеть статистику'), findsOneWidget);
  });

  testWidgets('Статистика показывает лидеров по сериям', (tester) async {
    await tester.pumpApp(const StatisticsScreen(), habits: buildDemoHabits());
    await tester.pumpAndSettle();
    expect(find.text('Лучшие серии'), findsOneWidget);
    expect(find.text('Английский язык'), findsOneWidget);
  });
}
