import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_study_tracker/core/layout/breakpoints.dart';
import 'package:habit_study_tracker/domain/entities/app_user.dart';
import 'package:habit_study_tracker/domain/entities/habit.dart';
import 'package:habit_study_tracker/domain/entities/study_goal.dart';
import 'package:habit_study_tracker/presentation/router/app_router.dart';

import '../helpers/fakes.dart';
import '../helpers/pump_app.dart';

void main() {
  final created = DateTime.now().subtract(const Duration(days: 3));
  final habits = [
    Habit(
      id: 'a',
      title: 'Медитация',
      categoryId: 'cat_health',
      createdAt: created,
    ),
    Habit(
      id: 'b',
      title: 'Зарядка',
      categoryId: 'cat_sport',
      createdAt: created,
    ),
  ];

  group('authRedirect (чистая функция)', () {
    test('не вошёл → /login с адресом возврата', () {
      expect(
        authRedirect(signedIn: false, uri: Uri.parse('/habit/a')),
        '/login?from=%2Fhabit%2Fa',
      );
      expect(authRedirect(signedIn: false, uri: Uri.parse('/today')), '/login');
      expect(authRedirect(signedIn: false, uri: Uri.parse('/login')), isNull);
    });

    test('вошёл и на /login → туда, откуда пришёл', () {
      expect(
        authRedirect(signedIn: true, uri: Uri.parse('/login?from=/goals')),
        '/goals',
      );
      expect(authRedirect(signedIn: true, uri: Uri.parse('/login')), '/today');
      expect(authRedirect(signedIn: true, uri: Uri.parse('/stats')), isNull);
    });
  });

  test('классы ширины окна', () {
    expect(Breakpoints.of(400), WindowSize.compact);
    expect(Breakpoints.of(700), WindowSize.medium);
    expect(Breakpoints.of(1280), WindowSize.expanded);
  });

  testWidgets('Без входа защищённый экран перенаправляет на логин, '
      'после входа — обратно', (tester) async {
    final auth = FakeAuthRepository(user: null);
    final router = await tester.pumpRouterApp(
      initialLocation: '/habit/a',
      habits: habits,
      auth: auth,
    );
    expect(locationOf(router), startsWith('/login'));
    expect(find.text('Продолжить без аккаунта'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('emailField')), 'me@mail.kz');
    await tester.enterText(
      find.byKey(const Key('passwordField')),
      FakeAuthRepository.password,
    );
    await tester.tap(find.byKey(const Key('submitButton')));
    await tester.pumpAndSettle();

    expect(locationOf(router), '/habit/a');
    expect(find.text('Медитация'), findsOneWidget);
  });

  testWidgets('Неверный пароль показывает ошибку', (tester) async {
    await tester.pumpRouterApp(auth: FakeAuthRepository(user: null));
    await tester.enterText(find.byKey(const Key('emailField')), 'me@mail.kz');
    await tester.enterText(find.byKey(const Key('passwordField')), 'wrong-1');
    await tester.tap(find.byKey(const Key('submitButton')));
    await tester.pumpAndSettle();
    expect(find.text('Неверный email или пароль'), findsOneWidget);
  });

  testWidgets('Без Firebase доступен только гостевой вход', (tester) async {
    final router = await tester.pumpRouterApp(
      auth: FakeAuthRepository(user: null, accounts: false),
    );
    expect(find.byKey(const Key('emailField')), findsNothing);
    await tester.tap(find.byKey(const Key('guestButton')));
    await tester.pumpAndSettle();
    expect(locationOf(router), '/today');
  });

  testWidgets('Выход из профиля возвращает на экран входа', (tester) async {
    final router = await tester.pumpRouterApp(
      auth: FakeAuthRepository(
        user: const AppUser(uid: 'u', email: 'a@b.c'),
      ),
    );
    await tester.tap(find.text('Профиль'));
    await tester.pumpAndSettle();
    expect(find.text('a@b.c'), findsWidgets);

    await tester.tap(find.byKey(const Key('signOutTile')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirmSignOut')));
    await tester.pumpAndSettle();
    expect(locationOf(router), startsWith('/login'));
  });

  testWidgets('Вкладки сохраняют свой стек (вложенная навигация)', (
    tester,
  ) async {
    final router = await tester.pumpRouterApp(habits: habits);

    // Вкладка «Профиль» → «Настройки» (внутри вкладки).
    await tester.tap(find.text('Профиль'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settingsTile')));
    await tester.pumpAndSettle();
    expect(locationOf(router), '/profile/settings');
    expect(find.byType(NavigationBar), findsOneWidget);

    // Уходим на «Статистику» и возвращаемся — настройки на месте.
    await tester.tap(find.text('Статистика'));
    await tester.pumpAndSettle();
    expect(locationOf(router), '/stats');
    await tester.tap(find.text('Профиль'));
    await tester.pumpAndSettle();
    expect(locationOf(router), '/profile/settings');

    // Повторное нажатие на активную вкладку — к её началу.
    await tester.tap(find.text('Профиль'));
    await tester.pumpAndSettle();
    expect(locationOf(router), '/profile');
  });

  testWidgets('Маршрут с параметром /habit/:id и редактирование', (
    tester,
  ) async {
    final router = await tester.pumpRouterApp(habits: habits);
    router.goNamed(AppRoutes.habit, pathParameters: {'id': 'b'});
    await tester.pumpAndSettle();
    expect(find.text('Зарядка'), findsOneWidget);
    // Детали открыты поверх нижней навигации.
    expect(find.byType(NavigationBar), findsNothing);

    await tester.tap(find.byTooltip('Изменить'));
    await tester.pumpAndSettle();
    expect(locationOf(router), '/habit/b/edit');
    await tester.enterText(find.byKey(const Key('titleField')), 'Бег');
    await tester.scrollUntilVisible(
      find.byKey(const Key('saveButton')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('saveButton')));
    await tester.pumpAndSettle();
    expect(locationOf(router), '/habit/b');
    expect(find.text('Бег'), findsOneWidget);
  });

  testWidgets('Прямая ссылка на редактирование ждёт загрузки данных', (
    tester,
  ) async {
    // Без ожидания форма открылась бы пустой и создала новую привычку.
    await tester.pumpRouterApp(
      initialLocation: '/habit/b/edit',
      habits: habits,
    );
    final field = tester.widget<TextField>(
      find.descendant(
        of: find.byKey(const Key('titleField')),
        matching: find.byType(TextField),
      ),
    );
    expect(field.controller!.text, 'Зарядка');
  });

  testWidgets('Неизвестный адрес — экран «Страница не найдена»', (
    tester,
  ) async {
    await tester.pumpRouterApp(initialLocation: '/nope');
    expect(find.text('Страница не найдена'), findsOneWidget);
  });

  testWidgets('Книга без объекта extra перенаправляет на поиск', (
    tester,
  ) async {
    final router = await tester.pumpRouterApp(
      initialLocation: '/materials/book',
    );
    expect(locationOf(router), '/materials');
  });

  testWidgets('Создание учебной цели и переход к ней', (tester) async {
    final router = await tester.pumpRouterApp(habits: habits);
    await tester.tap(find.text('Цели'));
    await tester.pumpAndSettle();
    expect(find.text('Учебных целей пока нет'), findsOneWidget);

    await tester.tap(find.byKey(const Key('addGoal')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('goalTitle')), 'Сессия');
    await tester.enterText(find.byKey(const Key('goalTarget')), '10');
    await tester.enterText(find.byKey(const Key('goalUnit')), 'задач');
    await tester.tap(find.text('Зарядка'));
    await tester.tap(find.byKey(const Key('goalSave')));
    await tester.pumpAndSettle();

    expect(locationOf(router), '/goals');
    expect(find.text('Сессия'), findsOneWidget);
    await tester.tap(find.text('Сессия'));
    await tester.pumpAndSettle();
    expect(locationOf(router), startsWith('/goals/goal_'));
    expect(find.text('Привязанные привычки'), findsOneWidget);
    // Вложенный экран вкладки: нижняя навигация видна.
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.byKey(const Key('addProgressButton')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('numberField')), '4');
    await tester.tap(find.byKey(const Key('numberSave')));
    await tester.pumpAndSettle();
    expect(find.text('40%'), findsOneWidget);
  });

  testWidgets('Категории: создание новой категории', (tester) async {
    await tester.pumpRouterApp(habits: habits, categories: const []);
    await tester.tap(find.text('Привычки'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('categoriesButton')));
    await tester.pumpAndSettle();
    expect(find.text('Категорий пока нет'), findsOneWidget);

    await tester.tap(find.byKey(const Key('addCategory')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('categoryName')), 'Учёба');
    await tester.tap(find.byKey(const Key('categorySave')));
    await tester.pumpAndSettle();
    expect(find.text('Учёба'), findsOneWidget);
  });

  testWidgets('Цели из данных: прогресс по привязанной привычке', (
    tester,
  ) async {
    await tester.pumpRouterApp(
      initialLocation: '/goals',
      habits: habits,
      goals: [
        StudyGoal(
          id: 'g',
          title: 'Медитировать 30 раз',
          target: 30,
          deadline: DateTime.now().add(const Duration(days: 10)),
          createdAt: DateTime.now(),
          manualProgress: 3,
        ),
      ],
    );
    expect(find.text('Медитировать 30 раз'), findsOneWidget);
    expect(find.text('10%'), findsOneWidget);
  });

  group('адаптивная вёрстка', () {
    testWidgets('альбомная ориентация — NavigationRail вместо нижней панели', (
      tester,
    ) async {
      await tester.pumpRouterApp(
        habits: habits,
        screen: TestScreens.phoneLandscape,
      );
      expect(find.byKey(const Key('navigationRail')), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.text('Медитация'), findsOneWidget);
    });

    testWidgets('планшет — список и детали привычки рядом', (tester) async {
      final router = await tester.pumpRouterApp(
        habits: habits,
        screen: TestScreens.tablet,
      );
      expect(find.byKey(const Key('navigationRail')), findsOneWidget);
      await tester.tap(find.text('Привычки').first);
      await tester.pumpAndSettle();
      expect(find.text('Выберите привычку слева'), findsOneWidget);

      await tester.tap(find.text('Зарядка'));
      await tester.pumpAndSettle();
      // Адрес не изменился: детали открыты в правой панели.
      expect(locationOf(router), '/habits');
      expect(find.text('Текущая серия'), findsOneWidget);
    });
  });
}
