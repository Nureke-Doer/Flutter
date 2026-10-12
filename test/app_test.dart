import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_study_tracker/app.dart';
import 'package:habit_study_tracker/core/di/injection.dart';
import 'package:habit_study_tracker/data/repositories/local_auth_repository.dart';
import 'package:habit_study_tracker/data/repositories/shared_prefs_settings_repository.dart';
import 'package:habit_study_tracker/domain/repositories/auth_repository.dart';
import 'package:habit_study_tracker/domain/repositories/habit_repository.dart';
import 'package:habit_study_tracker/domain/repositories/materials_repository.dart';
import 'package:habit_study_tracker/presentation/providers/settings_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/fakes.dart';
import 'helpers/hive_test_utils.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      SharedPrefsSettingsRepository.languageKey: 'ru',
    });
    await getIt.reset();
    await setUpTestHive();
    await configureDependencies();
    // Подменяем сетевой репозиторий фейком — тесты не ходят в интернет.
    getIt
      ..unregister<MaterialsRepository>()
      ..registerLazySingleton<MaterialsRepository>(FakeMaterialsRepository.new);
  });

  tearDown(tearDownTestHive);

  test('DI: репозитории и настройки — синглтоны', () {
    expect(
      identical(getIt<HabitRepository>(), getIt<HabitRepository>()),
      isTrue,
    );
    expect(
      identical(getIt<SettingsNotifier>(), getIt<SettingsNotifier>()),
      isTrue,
    );
  });

  test('При первом запуске добавляются демо-цели', () async {
    final habits = await getIt<HabitRepository>().watchHabits().first;
    expect(habits, isNotEmpty);
  });

  test('Тема сохраняется в SharedPreferences', () async {
    await getIt<SettingsNotifier>().setThemeMode(ThemeMode.dark);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(SharedPrefsSettingsRepository.themeKey), 'dark');
  });

  test('Гостевой режим запоминается между запусками', () async {
    final prefs = await SharedPreferences.getInstance();
    final first = LocalAuthRepository(prefs);
    expect(first.currentUser, isNull);
    expect(first.supportsAccounts, isFalse);
    await first.continueAsGuest();
    expect(LocalAuthRepository(prefs).currentUser?.isGuest, isTrue);
    await first.signOut();
    expect(LocalAuthRepository(prefs).currentUser, isNull);
    await expectLater(
      first.signInWithEmail('a@b.c', '123456'),
      throwsA(isA<AuthFailure>()),
    );
  });

  testWidgets('Приложение запускается и реагирует на смену темы', (
    tester,
  ) async {
    await tester.pumpWidget(const HabitStudyTrackerApp());
    await tester.pumpAndSettle();
    // Первый запуск: не вошёл → redirect на экран входа.
    expect(find.text('Продолжить без аккаунта'), findsOneWidget);
    await tester.tap(find.byKey(const Key('guestButton')));
    await tester.pumpAndSettle();
    expect(find.text('Сегодня'), findsWidgets);

    getIt<SettingsNotifier>().setThemeMode(ThemeMode.dark);
    await tester.pumpAndSettle();
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
  });
}
