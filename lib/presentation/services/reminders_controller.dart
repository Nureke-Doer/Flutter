import 'dart:async';

import '../../domain/entities/habit.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../domain/repositories/reminder_scheduler.dart';
import '../../domain/services/reminder_planner.dart';
import '../../l10n/generated/app_localizations.dart';
import '../providers/settings_notifier.dart';

/// Держит расписание напоминаний в актуальном состоянии: при каждом
/// изменении привычек, времени сводки или языка заново планирует
/// уведомления (с задержкой 500 мс, чтобы не дёргать систему на каждое
/// нажатие).
class RemindersController {
  RemindersController({
    required HabitRepository habits,
    required SettingsNotifier settings,
    required ReminderScheduler scheduler,
  }) : _habitsRepo = habits,
       _settings = settings,
       _scheduler = scheduler;

  final HabitRepository _habitsRepo;
  final SettingsNotifier _settings;
  final ReminderScheduler _scheduler;
  StreamSubscription<List<Habit>>? _subscription;
  Timer? _debounce;
  List<Habit> _habits = const [];

  void start() {
    _subscription = _habitsRepo.watchHabits().listen((h) {
      _habits = h;
      _schedule();
    });
    _settings.addListener(_schedule);
  }

  void _schedule() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final l10n = lookupAppLocalizations(_settings.locale);
      _scheduler.replaceAll(
        planReminders(
          _habits,
          summaryMinutes: _settings.dailySummaryMinutes,
          texts: ReminderTexts(
            habitBody: l10n.reminderHabitBody,
            summaryTitle: l10n.reminderSummaryTitle,
            summaryBody: l10n.reminderSummaryBody,
          ),
        ),
      );
    });
  }

  /// Тестовое уведомление из настроек.
  Future<void> showTest() async {
    await _scheduler.requestPermission();
    final l10n = lookupAppLocalizations(_settings.locale);
    await _scheduler.showNow(
      title: l10n.reminderTestTitle,
      body: l10n.reminderTestBody,
      payload: '/today',
    );
  }

  Future<void> dispose() async {
    _debounce?.cancel();
    _settings.removeListener(_schedule);
    await _subscription?.cancel();
  }
}
