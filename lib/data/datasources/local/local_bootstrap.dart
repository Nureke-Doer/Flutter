import 'dart:convert';

import 'package:hive_ce/hive.dart';

import '../../../core/utils/date_utils.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/habit.dart';
import '../../../domain/entities/habit_entry.dart';
import '../../models/category_model.dart';
import '../../models/habit_entry_model.dart';
import '../../models/habit_model.dart';
import '../../models/study_goal_model.dart';
import '../demo_habits.dart';
import 'local_collection.dart';
import 'hive_storage.dart';

/// Подготовка локальных данных при запуске:
/// 1. миграция данных старого формата (недели 4–6);
/// 2. демо-данные при самом первом запуске (только один раз).
class LocalBootstrap {
  LocalBootstrap({
    required this.habits,
    required this.entries,
    required this.categories,
    required this.goals,
    required Box<String> meta,
  }) : _meta = meta;

  static const seededKey = 'demo_seeded';
  static const migratedKey = 'migrated_v2';

  final LocalCollection habits;
  final LocalCollection entries;
  final LocalCollection categories;
  final LocalCollection goals;
  final Box<String> _meta;

  Future<void> run({DateTime? now}) async {
    await migrateLegacy();
    await seedIfNeeded(now: now);
  }

  /// При первом запуске добавляет демо-данные, чтобы приложение не было
  /// пустым. Если пользователь всё удалит — повторно не добавляются.
  Future<void> seedIfNeeded({DateTime? now}) async {
    if (_meta.get(seededKey) != null) return;
    if (habits.readAll().isEmpty) {
      final demo = buildDemoData(now);
      await categories.putAll({
        for (final c in demo.categories)
          c.id: CategoryModel.fromEntity(c).toJson(),
      });
      await habits.putAll({
        for (final h in demo.habits) h.id: HabitModel.fromEntity(h).toJson(),
      });
      await entries.putAll({
        for (final e in demo.entries)
          e.key: HabitEntryModel.fromEntity(e).toJson(),
      });
      await goals.putAll({
        for (final g in demo.goals) g.id: StudyGoalModel.fromEntity(g).toJson(),
      });
    }
    await _meta.put(seededKey, DateTime.now().toIso8601String());
  }

  /// Переносит привычки из формата недель 4–6, где отметки хранились
  /// списком `completedDays` внутри привычки, а тип был `habit` / `study`.
  Future<void> migrateLegacy() async {
    if (_meta.get(migratedKey) != null) return;
    if (await Hive.boxExists(HiveBoxes.legacyHabits)) {
      final legacy = await Hive.openBox<String>(HiveBoxes.legacyHabits);
      final converted = convertLegacy(legacy.values);
      if (converted.habits.isNotEmpty) {
        await categories.putAll({
          for (final c in converted.categories)
            c.id: CategoryModel.fromEntity(c).toJson(),
        });
        await habits.putAll({
          for (final h in converted.habits)
            h.id: HabitModel.fromEntity(h).toJson(),
        });
        await entries.putAll({
          for (final e in converted.entries)
            e.key: HabitEntryModel.fromEntity(e).toJson(),
        });
        // Старые пользователи уже видели демо-данные — второй раз не нужно.
        await _meta.put(seededKey, DateTime.now().toIso8601String());
      }
      await legacy.deleteFromDisk();
    }
    await _meta.put(migratedKey, DateTime.now().toIso8601String());
  }

  /// Чистая функция конвертации (удобно тестировать).
  static DemoData convertLegacy(Iterable<String> rawHabits) {
    const studyCategory = Category(
      id: 'cat_study',
      name: 'Учёба',
      colorValue: 0xFF8E24AA,
    );
    const habitsCategory = Category(
      id: 'cat_habits',
      name: 'Привычки',
      sortOrder: 1,
    );
    final habits = <Habit>[];
    final entries = <HabitEntry>[];
    var usesStudy = false;
    var usesHabits = false;

    for (final raw in rawHabits) {
      try {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        final isStudy = json['type'] == 'study';
        final minutes = (json['targetMinutes'] as num?)?.toDouble();
        final numeric = isStudy && minutes != null;
        final weekdays = (json['weekdays'] as List? ?? const [])
            .cast<int>()
            .toSet();
        if (isStudy) {
          usesStudy = true;
        } else {
          usesHabits = true;
        }

        final habit = Habit(
          id: json['id'] as String,
          title: json['title'] as String,
          description: json['description'] as String? ?? '',
          categoryId: isStudy ? studyCategory.id : habitsCategory.id,
          kind: numeric ? HabitKind.numeric : HabitKind.positive,
          unit: numeric ? 'мин' : null,
          target: numeric ? minutes : null,
          icon: HabitIcon.values.asNameMap()[json['icon']] ?? HabitIcon.check,
          colorValue: json['colorValue'] as int? ?? 0xFF00897B,
          schedule: weekdays.isEmpty || weekdays.length == 7
              ? const HabitSchedule.daily()
              : HabitSchedule.weekdays(weekdays),
          reminderMinutes: json['reminderMinutes'] as int?,
          createdAt: DateTime.parse(json['createdAt'] as String),
        );
        habits.add(habit);
        for (final day in (json['completedDays'] as List? ?? const [])) {
          entries.add(
            HabitEntry(
              habitId: habit.id,
              date: parseDay(day as String),
              value: numeric ? EntryAmount(minutes) : const EntryDone(),
            ),
          );
        }
      } on Object {
        // Повреждённую запись пропускаем.
        continue;
      }
    }
    return DemoData(
      categories: [
        if (usesStudy) studyCategory,
        if (usesHabits) habitsCategory,
      ],
      habits: habits,
      entries: entries,
      goals: const [],
    );
  }
}
