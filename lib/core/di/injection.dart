import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../data/datasources/remote/open_library_api.dart';
import '../../data/datasources/remote/quotes_api.dart';
import '../../data/repositories/in_memory_habit_repository.dart';
import '../../data/repositories/materials_repository_impl.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../domain/repositories/materials_repository.dart';
import '../../presentation/blocs/habits/habits_bloc.dart';
import '../../presentation/blocs/materials/materials_bloc.dart';
import '../../presentation/blocs/quote/quote_cubit.dart';
import '../../presentation/providers/settings_notifier.dart';
import '../network/dio_client.dart';

/// Глобальный контейнер зависимостей (Service Locator).
final GetIt getIt = GetIt.instance;

/// Регистрирует зависимости приложения. Вызывается один раз в `main()`.
///
/// - `registerLazySingleton` — один объект на всё приложение,
///   создаётся при первом обращении (репозитории, настройки).
/// - `registerFactory` — новый объект при каждом запросе (BLoC-и:
///   их жизненным циклом управляет `BlocProvider`).
void configureDependencies() {
  getIt
    // Сеть
    ..registerLazySingleton<Dio>(createDio)
    ..registerLazySingleton(() => OpenLibraryApi(getIt<Dio>()))
    ..registerLazySingleton(() => QuotesApi(getIt<Dio>()))
    // Репозитории
    ..registerLazySingleton<HabitRepository>(InMemoryHabitRepository.new)
    ..registerLazySingleton<MaterialsRepository>(
      () => MaterialsRepositoryImpl(
        booksApi: getIt<OpenLibraryApi>(),
        quotesApi: getIt<QuotesApi>(),
      ),
    )
    // Состояние
    ..registerLazySingleton<SettingsNotifier>(SettingsNotifier.new)
    ..registerFactory<HabitsBloc>(
      () => HabitsBloc(repository: getIt<HabitRepository>()),
    )
    ..registerFactory<MaterialsBloc>(
      () => MaterialsBloc(repository: getIt<MaterialsRepository>()),
    )
    ..registerFactory<QuoteCubit>(
      () => QuoteCubit(repository: getIt<MaterialsRepository>()),
    );
}
