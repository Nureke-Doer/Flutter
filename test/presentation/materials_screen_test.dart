import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_study_tracker/core/di/injection.dart';
import 'package:habit_study_tracker/core/error/failures.dart';
import 'package:habit_study_tracker/presentation/blocs/materials/materials_bloc.dart';
import 'package:habit_study_tracker/presentation/screens/materials_screen.dart';

import '../helpers/fakes.dart';
import '../helpers/pump_app.dart';

void main() {
  late FakeMaterialsRepository repository;

  setUp(() async {
    await getIt.reset();
    repository = FakeMaterialsRepository(totalFound: 3);
    getIt.registerFactory(
      () => MaterialsBloc(repository: repository, debounce: Duration.zero),
    );
  });

  testWidgets('Поиск показывает результаты', (tester) async {
    await tester.pumpApp(const MaterialsScreen());
    expect(find.text('Популярные темы'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'flutter');
    await tester.pumpAndSettle();

    expect(find.text('Книга 1'), findsOneWidget);
    expect(find.text('Найдено: 3'), findsOneWidget);
  });

  testWidgets('Нажатие на тему запускает поиск', (tester) async {
    await tester.pumpApp(const MaterialsScreen());
    await tester.tap(find.text('Algorithms'));
    await tester.pumpAndSettle();
    expect(repository.requests, ['Algorithms#1']);
  });

  testWidgets('Ошибка сети показывает сообщение и кнопку повтора', (
    tester,
  ) async {
    repository.failure = const NetworkFailure();
    await tester.pumpApp(const MaterialsScreen(initialQuery: 'dart'));
    await tester.pumpAndSettle();
    expect(find.text('Нет подключения к интернету'), findsOneWidget);

    repository.failure = null;
    await tester.tap(find.text('Повторить'));
    await tester.pumpAndSettle();
    expect(find.text('Книга 1'), findsOneWidget);
  });

  testWidgets('Пустой результат', (tester) async {
    repository.totalFound = 0;
    await tester.pumpApp(const MaterialsScreen(initialQuery: 'qwerty'));
    await tester.pumpAndSettle();
    expect(find.textContaining('ничего не найдено'), findsOneWidget);
  });

  testWidgets('В офлайн-режиме показывается плашка', (tester) async {
    repository.cachedAt = DateTime(2026, 9, 1, 12, 30);
    await tester.pumpApp(const MaterialsScreen(initialQuery: 'dart'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('offlineBanner')), findsOneWidget);
    expect(find.textContaining('Нет сети'), findsOneWidget);
  });

  testWidgets('Книгу можно сохранить и увидеть во вкладке «Сохранённые»', (
    tester,
  ) async {
    await tester.pumpApp(const MaterialsScreen(initialQuery: 'dart'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Сохранить').first);
    await tester.pumpAndSettle();
    expect(find.byTooltip('Убрать из сохранённых'), findsOneWidget);

    await tester.tap(find.text('Сохранённые'));
    await tester.pumpAndSettle();
    expect(find.text('Книга 1'), findsOneWidget);
  });

  testWidgets('История поиска показывается и очищается', (tester) async {
    repository.recent = ['linear algebra'];
    await tester.pumpApp(const MaterialsScreen());
    expect(find.text('Недавние запросы'), findsOneWidget);
    expect(find.text('linear algebra'), findsOneWidget);

    await tester.tap(find.text('Очистить'));
    await tester.pumpAndSettle();
    expect(find.text('linear algebra'), findsNothing);
  });
}
