import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_study_tracker/data/mock_habits.dart';
import 'package:habit_study_tracker/screens/habit_edit_screen.dart';
import 'package:habit_study_tracker/screens/today_screen.dart';

import 'helpers/pump_app.dart';

void main() {
  testWidgets('Экран «Сегодня» показывает цели и прогресс', (tester) async {
    await tester.pumpApp(const TodayScreen(), habits: buildMockHabits());
    await tester.pumpAndSettle();

    expect(find.text('Сегодня'), findsOneWidget);
    expect(find.text('Английский язык'), findsOneWidget);
    expect(find.textContaining('Выполнено'), findsOneWidget);
  });

  testWidgets('Пустой список показывает подсказку', (tester) async {
    await tester.pumpApp(const TodayScreen(), habits: const []);
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
}
