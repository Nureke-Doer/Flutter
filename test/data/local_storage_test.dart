import 'package:flutter_test/flutter_test.dart';
import 'package:habit_study_tracker/data/datasources/local/hive_storage.dart';
import 'package:habit_study_tracker/data/datasources/local/materials_local_data_source.dart';
import 'package:habit_study_tracker/data/models/habit_model.dart';
import 'package:habit_study_tracker/data/repositories/hive_favorites_repository.dart';
import 'package:habit_study_tracker/data/repositories/shared_prefs_settings_repository.dart';
import 'package:habit_study_tracker/domain/entities/app_settings.dart';
import 'package:habit_study_tracker/domain/entities/book.dart';
import 'package:habit_study_tracker/domain/entities/habit.dart';
import 'package:hive_ce/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/hive_test_utils.dart';

void main() {
  group('HabitModel', () {
    test('JSON туда и обратно сохраняет все поля', () {
      final habit = Habit(
        id: 'h',
        title: 'Чтение',
        description: 'описание',
        type: HabitType.study,
        icon: HabitIcon.book,
        colorValue: 0xFF123456,
        weekdays: const {2, 4},
        reminderMinutes: 75,
        targetMinutes: 20,
        createdAt: DateTime(2026, 1, 2, 3, 4),
        completedDays: {DateTime(2026, 1, 5), DateTime(2026, 1, 3)},
      );
      final json = HabitModel.fromEntity(habit).toJson();
      expect(json['completedDays'], ['2026-01-03', '2026-01-05']);
      expect(json['type'], 'study');
      expect(HabitModel.fromJson(json).toEntity(), habit);
    });

    test('неизвестное значение enum заменяется значением по умолчанию', () {
      final json = HabitModel.fromEntity(
        Habit(id: '1', title: 't', createdAt: DateTime(2026)),
      ).toJson()..['icon'] = 'rocket';
      expect(HabitModel.fromJson(json).toEntity().icon, HabitIcon.check);
    });
  });

  group('SharedPrefsSettingsRepository', () {
    test('значения по умолчанию', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = SharedPrefsSettingsRepository(
        await SharedPreferences.getInstance(),
        defaultLanguageCode: 'en',
      );
      expect(repo.load(), const AppSettings(languageCode: 'en'));
    });

    test('неподдерживаемый язык устройства заменяется русским', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = SharedPrefsSettingsRepository(
        await SharedPreferences.getInstance(),
        defaultLanguageCode: 'de',
      );
      expect(repo.load().languageCode, 'ru');
    });

    test('сохраняет тему и язык', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = SharedPrefsSettingsRepository(prefs);
      await repo.saveThemePreference(ThemePreference.dark);
      await repo.saveLanguageCode('en');

      final reloaded = SharedPrefsSettingsRepository(prefs).load();
      expect(reloaded.themePreference, ThemePreference.dark);
      expect(reloaded.languageCode, 'en');
    });
  });

  group('Hive: избранное и история', () {
    setUp(setUpTestHive);
    tearDown(tearDownTestHive);

    test('toggleFavorite добавляет и удаляет книгу целиком', () async {
      final repo = HiveFavoritesRepository(
        Hive.box<String>(HiveBoxes.favorites),
      );
      const book = Book(
        id: '/works/OL1W',
        title: 'Clean Code',
        authors: ['Robert C. Martin'],
        coverId: 42,
        firstPublishYear: 2008,
      );
      await repo.toggleFavorite(book);
      expect(await repo.watchFavorites().first, [book]);

      await repo.toggleFavorite(book);
      expect(await repo.watchFavorites().first, isEmpty);
    });

    test('история поиска: без дублей, новые первыми, не более 8', () async {
      final local = MaterialsLocalDataSource(
        cacheBox: Hive.box<String>(HiveBoxes.apiCache),
        metaBox: Hive.box<String>(HiveBoxes.meta),
      );
      for (var i = 0; i < 10; i++) {
        await local.addRecentQuery('q$i');
      }
      await local.addRecentQuery('Q5');
      final recent = local.recentQueries();
      expect(recent.first, 'Q5');
      expect(recent.length, MaterialsLocalDataSource.maxRecentQueries);
      expect(recent.where((q) => q.toLowerCase() == 'q5').length, 1);
    });
  });
}
