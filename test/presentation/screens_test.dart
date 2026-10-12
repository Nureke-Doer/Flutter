import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_study_tracker/data/datasources/demo_habits.dart';
import 'package:habit_study_tracker/domain/entities/habit.dart';
import 'package:habit_study_tracker/presentation/providers/settings_notifier.dart';
import 'package:habit_study_tracker/presentation/screens/habit_edit_screen.dart';
import 'package:habit_study_tracker/presentation/screens/settings_screen.dart';
import 'package:habit_study_tracker/presentation/screens/statistics_screen.dart';
import 'package:habit_study_tracker/presentation/screens/today_screen.dart';

import '../helpers/fakes.dart';
import '../helpers/pump_app.dart';

void main() {
  testWidgets('Экран «Сегодня» показывает привычки и прогресс', (tester) async {
    final demo = buildDemoData();
    await tester.pumpApp(
      const TodayScreen(),
      habits: demo.habits,
      entries: demo.entries,
    );
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

  testWidgets('Архивные привычки не показываются на «Сегодня»', (tester) async {
    await tester.pumpApp(
      const TodayScreen(),
      habits: [
        Habit(
          id: 'old',
          title: 'Старая',
          archived: true,
          createdAt: DateTime(2026),
        ),
      ],
    );
    await tester.pumpAndSettle();
    expect(find.text('Старая'), findsNothing);
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

  testWidgets('Форма: числовая привычка с единицей и целью', (tester) async {
    Habit? saved;
    await tester.pumpApp(
      Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async {
              saved = await Navigator.of(context).push<Habit>(
                MaterialPageRoute(builder: (_) => const HabitEditScreen()),
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('titleField')), 'Чтение');
    await tester.tap(find.text('Число'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('unitField')), 'стр.');
    await tester.enterText(find.byKey(const Key('targetField')), '20');
    await tester.tap(find.text('N раз в неделю'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const Key('saveButton')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('saveButton')));
    await tester.pumpAndSettle();

    expect(saved?.title, 'Чтение');
    expect(saved?.kind, HabitKind.numeric);
    expect(saved?.unit, 'стр.');
    expect(saved?.target, 20);
    expect(saved?.schedule, const HabitSchedule.timesPerWeek(3));
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

  testWidgets('Статистика показывает пустое состояние без привычек', (
    tester,
  ) async {
    await tester.pumpApp(const StatisticsScreen(), habits: const []);
    await tester.pumpAndSettle();
    expect(
      find.text('Добавь привычки, чтобы увидеть статистику'),
      findsOneWidget,
    );
  });

  testWidgets('Статистика показывает лидеров по сериям', (tester) async {
    final demo = buildDemoData();
    await tester.pumpApp(
      const StatisticsScreen(),
      habits: demo.habits,
      entries: demo.entries,
    );
    await tester.pumpAndSettle();
    expect(find.text('Лучшие серии'), findsOneWidget);
    expect(find.text('Английский язык'), findsOneWidget);
  });
}
