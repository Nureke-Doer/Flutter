import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_study_tracker/data/datasources/demo_habits.dart';
import 'package:habit_study_tracker/domain/entities/habit.dart';
import 'package:habit_study_tracker/presentation/widgets/habit_tile.dart';

import '../helpers/pump_app.dart';

void main() {
  final today = DateTime.now();
  Habit habit(String id, String title, {HabitKind kind = HabitKind.positive}) =>
      Habit(
        id: id,
        title: title,
        kind: kind,
        unit: kind == HabitKind.numeric ? 'стр.' : null,
        target: kind == HabitKind.numeric ? 20 : null,
        categoryId: 'cat_study',
        createdAt: today.subtract(const Duration(days: 3)),
      );

  Finder checkOf(String title) => find.descendant(
    of: find.widgetWithText(HabitTile, title),
    matching: find.byType(EntryButton),
  );

  testWidgets('Нажатие на кружок отмечает привычку и меняет прогресс', (
    tester,
  ) async {
    await tester.pumpRouterApp(
      habits: [habit('a', 'Медитация'), habit('b', 'Зарядка')],
    );
    await tester.pumpAndSettle();
    expect(find.text('Выполнено 0 из 2'), findsOneWidget);

    await tester.tap(checkOf('Медитация'));
    await tester.pumpAndSettle();
    expect(find.text('Выполнено 1 из 2'), findsOneWidget);
    expect(find.text('1 день'), findsOneWidget);

    // Повторное нажатие снимает отметку.
    await tester.tap(checkOf('Медитация'));
    await tester.pumpAndSettle();
    expect(find.text('Выполнено 0 из 2'), findsOneWidget);
  });

  testWidgets('Долгое нажатие: ✘ «сорвался» для отказа от вредного', (
    tester,
  ) async {
    await tester.pumpRouterApp(
      habits: [habit('q', 'Не курить', kind: HabitKind.quit)],
    );
    await tester.pumpAndSettle();

    await tester.longPress(checkOf('Не курить'));
    await tester.pumpAndSettle();
    expect(find.text('Удержался'), findsOneWidget);
    await tester.tap(find.text('Сорвался'));
    await tester.pumpAndSettle();

    final button = tester.widget<EntryButton>(checkOf('Не курить'));
    expect(button.value?.isFailure, isTrue);
    expect(find.text('Выполнено 0 из 1'), findsOneWidget);
  });

  testWidgets('Числовая привычка: ввод числа засчитывает день', (tester) async {
    await tester.pumpRouterApp(
      habits: [habit('r', 'Чтение', kind: HabitKind.numeric)],
    );
    await tester.pumpAndSettle();

    await tester.tap(checkOf('Чтение'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('amountField')), '25');
    await tester.tap(find.byKey(const Key('amountSave')));
    await tester.pumpAndSettle();

    expect(find.text('Выполнено 1 из 1'), findsOneWidget);
    expect(find.text('25 / 20 стр.'), findsOneWidget);
  });

  testWidgets('Экран деталей обновляется после отметки и удаляет привычку', (
    tester,
  ) async {
    await tester.pumpRouterApp(habits: [habit('h1', 'Медитация')]);

    await tester.tap(find.text('Медитация'));
    await tester.pumpAndSettle();
    expect(find.text('Отметить сегодня'), findsOneWidget);

    await tester.tap(find.byKey(const Key('toggleTodayButton')));
    await tester.pumpAndSettle();
    expect(find.text('Сегодня: Выполнил'), findsOneWidget);

    await tester.tap(find.byTooltip('Удалить'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Удалить'));
    await tester.pumpAndSettle();

    expect(find.text('Медитация'), findsNothing);
    expect(find.text('На сегодня ничего не запланировано'), findsOneWidget);

    // Отмена удаления через SnackBar возвращает привычку вместе с отметкой.
    await tester.tap(find.text('Отменить'));
    await tester.pumpAndSettle();
    expect(find.text('Медитация'), findsOneWidget);
    expect(find.text('Выполнено 1 из 1'), findsOneWidget);
  });

  testWidgets('Демо-данные: привычки сгруппированы по категориям', (
    tester,
  ) async {
    final demo = buildDemoData();
    await tester.pumpRouterApp(habits: demo.habits, entries: demo.entries);
    await tester.pumpAndSettle();
    expect(find.text('Учёба'), findsOneWidget);
    expect(find.text('Английский язык'), findsOneWidget);
  });
}
