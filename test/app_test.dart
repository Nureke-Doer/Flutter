import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_study_tracker/app.dart';
import 'package:habit_study_tracker/core/di/injection.dart';
import 'package:habit_study_tracker/domain/repositories/habit_repository.dart';
import 'package:habit_study_tracker/presentation/providers/settings_notifier.dart';

void main() {
  setUp(() async {
    await getIt.reset();
    configureDependencies();
  });

  test('DI: репозиторий и настройки — синглтоны', () {
    expect(
      identical(getIt<HabitRepository>(), getIt<HabitRepository>()),
      isTrue,
    );
    expect(
      identical(getIt<SettingsNotifier>(), getIt<SettingsNotifier>()),
      isTrue,
    );
  });

  testWidgets('Приложение запускается и реагирует на смену темы', (
    tester,
  ) async {
    await tester.pumpWidget(const HabitStudyTrackerApp());
    await tester.pumpAndSettle();
    expect(find.text('Сегодня'), findsWidgets);

    getIt<SettingsNotifier>().setThemeMode(ThemeMode.dark);
    await tester.pumpAndSettle();
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
  });
}
