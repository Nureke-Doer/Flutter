import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_study_tracker/data/datasources/demo_habits.dart';
import 'package:habit_study_tracker/domain/entities/habit.dart';
import 'package:habit_study_tracker/presentation/screens/home_shell.dart';
import 'package:habit_study_tracker/presentation/widgets/habit_tile.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('Нажатие на кружок отмечает цель и меняет прогресс', (
    tester,
  ) async {
    await tester.pumpApp(const HomeShell(), habits: buildDemoHabits());
    await tester.pumpAndSettle();

    final before =
        find.textContaining('Выполнено').evaluate().single.widget as Text;

    // Отмечаем первую невыполненную цель в списке «Сегодня».
    final checks = find.descendant(
      of: find.byType(HabitTile),
      matching: find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.checked == false,
      ),
    );
    expect(checks, findsWidgets);
    await tester.tap(checks.first);
    await tester.pumpAndSettle();

    final after =
        find.textContaining('Выполнено').evaluate().single.widget as Text;
    expect(after.data, isNot(before.data));
  });

  testWidgets('Экран деталей обновляется после отметки и удаляет цель', (
    tester,
  ) async {
    final today = DateTime.now();
    final habit = Habit(
      id: 'h1',
      title: 'Медитация',
      createdAt: today.subtract(const Duration(days: 3)),
    );
    await tester.pumpApp(const HomeShell(), habits: [habit]);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Медитация'));
    await tester.pumpAndSettle();
    expect(find.text('Отметить сегодня'), findsOneWidget);

    await tester.tap(find.byKey(const Key('toggleTodayButton')));
    await tester.pumpAndSettle();
    expect(find.text('Выполнено сегодня'), findsOneWidget);

    await tester.tap(find.byTooltip('Удалить'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Удалить'));
    await tester.pumpAndSettle();

    expect(find.text('Медитация'), findsNothing);
    expect(find.text('На сегодня ничего не запланировано'), findsOneWidget);

    // Отмена удаления через SnackBar возвращает цель.
    await tester.tap(find.text('Отменить'));
    await tester.pumpAndSettle();
    expect(find.text('Медитация'), findsOneWidget);
  });
}
