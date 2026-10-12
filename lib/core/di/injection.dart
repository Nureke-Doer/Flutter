import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/local/hive_storage.dart';
import '../../data/datasources/local/local_bootstrap.dart';
import '../../data/datasources/local/local_collection.dart';
import '../../data/datasources/local/materials_local_data_source.dart';
import '../../data/datasources/remote/firestore_sync_data_source.dart';
import '../../data/datasources/remote/open_library_api.dart';
import '../../data/datasources/remote/quotes_api.dart';
import '../../data/repositories/firebase_auth_repository.dart';
import '../../data/repositories/hive_category_repository.dart';
import '../../data/repositories/hive_favorites_repository.dart';
import '../../data/repositories/hive_goal_repository.dart';
import '../../data/repositories/hive_habit_repository.dart';
import '../../data/repositories/hive_metric_repository.dart';
import '../../data/repositories/local_auth_repository.dart';
import '../../data/repositories/materials_repository_impl.dart';
import '../../data/repositories/shared_prefs_settings_repository.dart';
import '../../data/services/local_notifications_scheduler.dart';
import '../../data/services/push_service.dart';
import '../../data/sync/sync_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../domain/repositories/goal_repository.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../domain/repositories/materials_repository.dart';
import '../../domain/repositories/metric_repository.dart';
import '../../domain/repositories/reminder_scheduler.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../presentation/blocs/auth/auth_cubit.dart';
import '../../presentation/blocs/categories/categories_cubit.dart';
import '../../presentation/blocs/favorites/favorites_cubit.dart';
import '../../presentation/blocs/goals/goals_cubit.dart';
import '../../presentation/blocs/habits/habits_bloc.dart';
import '../../presentation/blocs/materials/materials_bloc.dart';
import '../../presentation/blocs/metrics/metrics_cubit.dart';
import '../../presentation/blocs/quote/quote_cubit.dart';
import '../../presentation/providers/settings_notifier.dart';
import '../../presentation/services/reminders_controller.dart';
import '../network/dio_client.dart';

/// Глобальный контейнер зависимостей (Service Locator).
final GetIt getIt = GetIt.instance;

/// Регистрирует зависимости приложения. Вызывается один раз в `main()`
/// после `Hive.initFlutter()` и `initFirebase()`.
///
/// [firebaseReady] — удалось ли подключить Firebase. Если нет (проект не
/// настроен, тесты), регистрируются локальные реализации: приложение
/// работает в гостевом режиме без облака.
///
/// - `registerSingleton` — готовый объект (SharedPreferences, коробки Hive).
/// - `registerLazySingleton` — один объект на всё приложение,
///   создаётся при первом обращении (репозитории, настройки).
/// - `registerFactory` — новый объект при каждом запросе (BLoC-и:
///   их жизненным циклом управляет `BlocProvider`).
Future<void> configureDependencies({bool firebaseReady = false}) async {
  // Локальные хранилища
  final prefs = await SharedPreferences.getInstance();
  await openHiveBoxes();
  final habits = LocalCollection('habits', hiveBox(HiveBoxes.habits));
  final entries = LocalCollection('entries', hiveBox(HiveBoxes.entries));
  final categories = LocalCollection(
    'categories',
    hiveBox(HiveBoxes.categories),
  );
  final goals = LocalCollection('goals', hiveBox(HiveBoxes.goals));
  final metrics = LocalCollection('metrics', hiveBox(HiveBoxes.metrics));
  final metricRules = LocalCollection(
    'metric_rules',
    hiveBox(HiveBoxes.metricRules),
  );
  // Миграция старого формата и демо-данные при первом запуске.
  await LocalBootstrap(
    habits: habits,
    entries: entries,
    categories: categories,
    goals: goals,
    meta: hiveBox(HiveBoxes.meta),
  ).run();

  getIt
    ..registerSingleton<SharedPreferences>(prefs)
    // Локальные уведомления — только на Android/iOS.
    ..registerSingleton<ReminderScheduler>(
      _isMobile ? LocalNotificationsScheduler() : const NoopReminderScheduler(),
    )
    // Сеть
    ..registerLazySingleton<Dio>(createDio)
    ..registerLazySingleton(() => OpenLibraryApi(getIt<Dio>()))
    ..registerLazySingleton(() => QuotesApi(getIt<Dio>()))
    ..registerLazySingleton(
      () => MaterialsLocalDataSource(
        cacheBox: Hive.box<String>(HiveBoxes.apiCache),
        metaBox: Hive.box<String>(HiveBoxes.meta),
      ),
    )
    // Репозитории
    ..registerSingleton<HabitRepository>(
      HiveHabitRepository(habits: habits, entries: entries),
    )
    ..registerSingleton<CategoryRepository>(HiveCategoryRepository(categories))
    ..registerSingleton<GoalRepository>(HiveGoalRepository(goals))
    ..registerSingleton<MetricRepository>(
      HiveMetricRepository(metrics: metrics, rules: metricRules),
    )
    ..registerLazySingleton<MaterialsRepository>(
      () => MaterialsRepositoryImpl(
        booksApi: getIt<OpenLibraryApi>(),
        quotesApi: getIt<QuotesApi>(),
        local: getIt<MaterialsLocalDataSource>(),
      ),
    )
    ..registerLazySingleton<FavoritesRepository>(
      () => HiveFavoritesRepository(Hive.box<String>(HiveBoxes.favorites)),
    )
    ..registerLazySingleton<SettingsRepository>(
      () => SharedPrefsSettingsRepository(
        getIt<SharedPreferences>(),
        defaultLanguageCode: PlatformDispatcher.instance.locale.languageCode,
      ),
    )
    // Состояние
    ..registerLazySingleton<RemindersController>(
      () => RemindersController(
        habits: getIt<HabitRepository>(),
        settings: getIt<SettingsNotifier>(),
        scheduler: getIt<ReminderScheduler>(),
      ),
    )
    ..registerLazySingleton<SettingsNotifier>(
      () => SettingsNotifier(getIt<SettingsRepository>()),
    )
    ..registerFactory<AuthCubit>(
      () => AuthCubit(repository: getIt<AuthRepository>()),
    )
    ..registerFactory<HabitsBloc>(
      () => HabitsBloc(repository: getIt<HabitRepository>()),
    )
    ..registerFactory<CategoriesCubit>(
      () => CategoriesCubit(repository: getIt<CategoryRepository>()),
    )
    ..registerFactory<GoalsCubit>(
      () => GoalsCubit(repository: getIt<GoalRepository>()),
    )
    ..registerFactory<MetricsCubit>(
      () => MetricsCubit(
        metricRepository: getIt<MetricRepository>(),
        habitRepository: getIt<HabitRepository>(),
      ),
    )
    ..registerFactory<MaterialsBloc>(
      () => MaterialsBloc(repository: getIt<MaterialsRepository>()),
    )
    ..registerFactory<QuoteCubit>(
      () => QuoteCubit(repository: getIt<MaterialsRepository>()),
    )
    ..registerFactory<FavoritesCubit>(
      () => FavoritesCubit(repository: getIt<FavoritesRepository>()),
    );

  // Неделя 8: Firebase (если настроен) или локальные реализации.
  if (firebaseReady) {
    final firestore = FirebaseFirestore.instance
      // Офлайн-кэш Firestore: записи без сети ставятся в очередь.
      ..settings = const Settings(persistenceEnabled: true);
    getIt
      ..registerSingleton<AuthRepository>(
        FirebaseAuthRepository(FirebaseAuth.instance, prefs),
      )
      ..registerSingleton<FirebaseFirestore>(firestore)
      ..registerSingleton<SyncService>(
        SyncService(
          collections: [
            habits,
            entries,
            categories,
            goals,
            metrics,
            metricRules,
          ],
          remote: FirestoreSyncDataSource(firestore),
          meta: hiveBox(HiveBoxes.meta),
        ),
      );
    if (_isMobile) {
      getIt.registerSingleton<PushService>(
        PushService(
          messaging: FirebaseMessaging.instance,
          firestore: firestore,
          notifications: getIt<ReminderScheduler>(),
        ),
      );
    }
  } else {
    getIt.registerSingleton<AuthRepository>(LocalAuthRepository(prefs));
  }
}

/// Android или iOS (в браузере и в тестах — нет).
bool get _isMobile =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);
