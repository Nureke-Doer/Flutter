import 'package:get_it/get_it.dart';

import '../../data/repositories/in_memory_habit_repository.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../presentation/blocs/habits/habits_bloc.dart';
import '../../presentation/providers/settings_notifier.dart';

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
    ..registerLazySingleton<HabitRepository>(InMemoryHabitRepository.new)
    ..registerLazySingleton<SettingsNotifier>(SettingsNotifier.new)
    ..registerFactory<HabitsBloc>(
      () => HabitsBloc(repository: getIt<HabitRepository>()),
    );
}
