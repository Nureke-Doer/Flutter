import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_study_tracker/domain/entities/app_settings.dart';
import 'package:habit_study_tracker/domain/entities/habit.dart';
import 'package:habit_study_tracker/domain/entities/metric.dart';
import 'package:habit_study_tracker/presentation/providers/settings_notifier.dart';
import 'package:habit_study_tracker/presentation/widgets/habit_tile.dart';

import '../helpers/fakes.dart';
import '../helpers/pump_app.dart';

void main() {
  final habits = [
    Habit(
      id: 'sport',
      title: 'Спорт',
      categoryId: 'cat_sport',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  SettingsNotifier settings({required bool gamification}) => SettingsNotifier(
    FakeSettingsRepository(AppSettings(gamificationEnabled: gamification)),
  );

  testWidgets('Модуль выключен — нигде нет упоминаний метрик', (tester) async {
    final router = await tester.pumpRouterApp(
      habits: habits,
      settings: settings(gamification: false),
      metrics: FakeMetricRepository(metrics: [MetricPresets.money('money')]),
    );
    expect(find.byKey(const Key('metricsStrip')), findsNothing);

    await tester.tap(find.text('Профиль'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('metricsTile')), findsNothing);

    // Даже по прямой ссылке экран метрик недоступен.
    router.go('/profile/metrics');
    await tester.pumpAndSettle();
    expect(locationOf(router), '/profile');

    router.go('/habit/sport/edit');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('metricRulesSection')), findsNothing);
  });

  testWidgets('Включение, пресет Money, связь с привычкой, плашка и история', (
    tester,
  ) async {
    final notifier = settings(gamification: false);
    final router = await tester.pumpRouterApp(
      habits: habits,
      settings: notifier,
    );

    // 1. Включаем модуль в настройках.
    router.go('/profile/settings');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('gamificationSwitch')));
    await tester.pumpAndSettle();
    expect(notifier.gamificationEnabled, isTrue);

    // 2. Создаём метрику из пресета Money.
    router.go('/profile/metrics');
    await tester.pumpAndSettle();
    expect(find.text('Метрик пока нет'), findsOneWidget);
    await tester.tap(find.byKey(const Key('addMetric')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('presetMoney')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('metricSave')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('metricSave')));
    await tester.pumpAndSettle();
    expect(find.text('Money'), findsOneWidget);

    // 3. Привязываем привычку: награда 1000 за ✔.
    router.go('/habit/sport/edit');
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('metricRulesSection')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('metricRulesSection')));
    await tester.pumpAndSettle();
    final ruleSwitch = find.byWidgetPredicate(
      (w) => w is SwitchListTile && w.key.toString().contains('rule_metric_'),
    );
    await tester.scrollUntilVisible(
      ruleSwitch,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(ruleSwitch);
    await tester.pumpAndSettle();
    final reward = find.byWidgetPredicate(
      (w) => w is TextField && w.key.toString().contains('reward_'),
    );
    await tester.enterText(reward, '1000');
    await tester.scrollUntilVisible(
      find.byKey(const Key('saveButton')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('saveButton')));
    await tester.pumpAndSettle();

    // 4. Отмечаем привычку на «Сегодня» — плашка показывает +1000.
    router.go('/today');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('metricsStrip')), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.widgetWithText(HabitTile, 'Спорт'),
        matching: find.byType(EntryButton),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('+1,000 тг'), findsOneWidget);

    // 5. Экран метрики: значение и строка истории.
    await tester.tap(find.textContaining('Money:'));
    await tester.pumpAndSettle();
    expect(locationOf(router), startsWith('/profile/metrics/metric_'));
    expect(find.byKey(const Key('metricValue')), findsOneWidget);
    expect(find.text('История по дням'), findsOneWidget);
    expect(find.text('+1,000 тг'), findsWidgets); // прирост и итог дня
  });
}
