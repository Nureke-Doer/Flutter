import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/local/hive_storage.dart';
import '../../data/datasources/local/materials_local_data_source.dart';
import '../../data/datasources/remote/open_library_api.dart';
import '../../data/datasources/remote/quotes_api.dart';
import '../../data/repositories/hive_favorites_repository.dart';
import '../../data/repositories/hive_habit_repository.dart';
import '../../data/repositories/materials_repository_impl.dart';
import '../../data/repositories/shared_prefs_settings_repository.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../domain/repositories/materials_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../presentation/blocs/favorites/favorites_cubit.dart';
import '../../presentation/blocs/habits/habits_bloc.dart';
import '../../presentation/blocs/materials/materials_bloc.dart';
import '../../presentation/blocs/quote/quote_cubit.dart';
import '../../presentation/providers/settings_notifier.dart';
import '../network/dio_client.dart';

/// Глобальный контейнер зависимостей (Service Locator).
final GetIt getIt = GetIt.instance;

/// Регистрирует зависимости приложения. Вызывается один раз в `main()`
/// после `Hive.initFlutter()`.
///
/// - `registerSingleton` — готовый объект (SharedPreferences, коробки Hive).
/// - `registerLazySingleton` — один объект на всё приложение,
///   создаётся при первом обращении (репозитории, настройки).
/// - `registerFactory` — новый объект при каждом запросе (BLoC-и:
///   их жизненным циклом управляет `BlocProvider`).
Future<void> configureDependencies() async {
  // Локальные хранилища
  final prefs = await SharedPreferences.getInstance();
  await openHiveBoxes();
  final habitRepository = HiveHabitRepository(
    habitsBox: Hive.box<String>(HiveBoxes.habits),
    metaBox: Hive.box<String>(HiveBoxes.meta),
  );
  await habitRepository.seedIfNeeded();

  getIt
    ..registerSingleton<SharedPreferences>(prefs)
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
    ..registerSingleton<HabitRepository>(habitRepository)
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
    ..registerLazySingleton<SettingsNotifier>(
      () => SettingsNotifier(getIt<SettingsRepository>()),
    )
    ..registerFactory<HabitsBloc>(
      () => HabitsBloc(repository: getIt<HabitRepository>()),
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
}
