import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_study_tracker/screens/home_shell.dart';

import 'helpers/pump_app.dart';

void main() {
  testWidgets('Нажатие на кружок отмечает цель и меняет прогресс', (
    tester,
  ) async {
    await tester.pumpApp(const HomeShell());
    await tester.pumpAndSettle();

    final before =
        find.textContaining('Выполнено').evaluate().single.widget as Text;

    // Отмечаем «Утреннюю зарядку» (если она запланирована на сегодня)
    // или любую другую невыполненную цель — первую найденную.
    final checks = find.byWidgetPredicate(
      (w) => w is Semantics && w.properties.checked == false,
    );
    expect(checks, findsWidgets);
    await tester.tap(checks.first);
    await tester.pumpAndSettle();

    final after =
        find.textContaining('Выполнено').evaluate().single.widget as Text;
    expect(after.data, isNot(before.data));
  });
}
