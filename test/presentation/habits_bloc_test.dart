import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_study_tracker/domain/entities/habit.dart';
import 'package:habit_study_tracker/domain/entities/habit_entry.dart';
import 'package:habit_study_tracker/domain/entities/habit_history.dart';
import 'package:habit_study_tracker/domain/repositories/habit_repository.dart';
import 'package:habit_study_tracker/presentation/blocs/habits/habits_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockHabitRepository extends Mock implements HabitRepository {}

void main() {
  final day = DateTime(2026, 9, 9);
  final habitA = Habit(id: 'a', title: 'A', createdAt: day);
  final numeric = Habit(
    id: 'n',
    title: 'Чтение',
    kind: HabitKind.numeric,
    target: 20,
    createdAt: day,
  );
  final entryA = HabitEntry(habitId: 'a', date: day, value: const EntryDone());

  late MockHabitRepository repository;

  setUpAll(() {
    registerFallbackValue(habitA);
    registerFallbackValue(DateTime(2000));
    registerFallbackValue(<HabitEntry>[]);
  });

  setUp(() {
    repository = MockHabitRepository();
    when(
      () => repository.watchHabits(),
    ).thenAnswer((_) => Stream.value([habitA, numeric]));
    when(
      () => repository.watchEntries(),
    ).thenAnswer((_) => Stream.value([entryA]));
    when(() => repository.saveHabit(any())).thenAnswer((_) async {});
    when(() => repository.deleteHabit(any())).thenAnswer((_) async {});
    when(
      () => repository.setEntry(any(), any(), any()),
    ).thenAnswer((_) async {});
    when(() => repository.restoreEntries(any())).thenAnswer((_) async {});
  });

  HabitsBloc buildBloc() => HabitsBloc(repository: repository);

  HabitsState loaded({Map<String, HabitHistory> histories = const {}}) =>
      HabitsState(
        status: HabitsStatus.success,
        habits: [habitA, numeric],
        histories: histories,
      );

  test('начальное состояние — initial и пустой список', () {
    expect(buildBloc().state, const HabitsState());
  });

  group('HabitsSubscriptionRequested', () {
    blocTest<HabitsBloc, HabitsState>(
      'загружает привычки и группирует отметки по привычкам',
      build: buildBloc,
      act: (bloc) => bloc.add(const HabitsSubscriptionRequested()),
      verify: (bloc) {
        expect(bloc.state.status, HabitsStatus.success);
        expect(bloc.state.habits, [habitA, numeric]);
        expect(bloc.state.historyOf('a').valueOn(day), const EntryDone());
        expect(bloc.state.historyOf('n').isEmpty, isTrue);
      },
    );

    blocTest<HabitsBloc, HabitsState>(
      'выдаёт failure при ошибке потока',
      setUp: () => when(
        () => repository.watchHabits(),
      ).thenAnswer((_) => Stream.error(Exception('oops'))),
      build: buildBloc,
      act: (bloc) => bloc.add(const HabitsSubscriptionRequested()),
      expect: () => contains(
        isA<HabitsState>().having(
          (s) => s.status,
          'status',
          HabitsStatus.failure,
        ),
      ),
    );
  });

  group('HabitQuickToggled', () {
    blocTest<HabitsBloc, HabitsState>(
      'пустой день → ✔',
      build: buildBloc,
      seed: loaded,
      act: (bloc) => bloc.add(HabitQuickToggled('a', day)),
      verify: (_) => verify(
        () => repository.setEntry('a', day, const EntryDone()),
      ).called(1),
    );

    blocTest<HabitsBloc, HabitsState>(
      '✔ → пусто',
      build: buildBloc,
      seed: () => loaded(
        histories: {
          'a': HabitHistory({day: const EntryDone()}),
        },
      ),
      act: (bloc) => bloc.add(HabitQuickToggled('a', day)),
      verify: (_) =>
          verify(() => repository.setEntry('a', day, null)).called(1),
    );

    blocTest<HabitsBloc, HabitsState>(
      'числовая привычка получает значение цели',
      build: buildBloc,
      seed: loaded,
      act: (bloc) => bloc.add(HabitQuickToggled('n', day)),
      verify: (_) => verify(
        () => repository.setEntry('n', day, const EntryAmount(20)),
      ).called(1),
    );

    blocTest<HabitsBloc, HabitsState>(
      'ничего не делает для неизвестной привычки',
      build: buildBloc,
      seed: loaded,
      act: (bloc) => bloc.add(HabitQuickToggled('missing', day)),
      verify: (_) =>
          verifyNever(() => repository.setEntry(any(), any(), any())),
    );
  });

  blocTest<HabitsBloc, HabitsState>(
    'HabitEntrySet записывает ✘',
    build: buildBloc,
    act: (bloc) => bloc.add(HabitEntrySet('a', day, const EntryFailed())),
    verify: (_) => verify(
      () => repository.setEntry('a', day, const EntryFailed()),
    ).called(1),
  );

  blocTest<HabitsBloc, HabitsState>(
    'HabitSaved сохраняет привычку в репозитории',
    build: buildBloc,
    act: (bloc) => bloc.add(HabitSaved(numeric)),
    verify: (_) => verify(() => repository.saveHabit(numeric)).called(1),
  );

  blocTest<HabitsBloc, HabitsState>(
    'HabitArchiveToggled отправляет в архив',
    build: buildBloc,
    seed: loaded,
    act: (bloc) => bloc.add(const HabitArchiveToggled('a')),
    verify: (_) => verify(
      () => repository.saveHabit(habitA.copyWith(archived: true)),
    ).called(1),
  );

  group('удаление', () {
    blocTest<HabitsBloc, HabitsState>(
      'HabitDeleted запоминает привычку и её отметки',
      build: buildBloc,
      seed: () => loaded(
        histories: {
          'a': HabitHistory({day: const EntryDone()}),
        },
      ),
      act: (bloc) => bloc.add(const HabitDeleted('a')),
      verify: (bloc) {
        expect(bloc.state.lastDeleted, habitA);
        expect(bloc.state.lastDeletedEntries, [entryA]);
        verify(() => repository.deleteHabit('a')).called(1);
      },
    );

    blocTest<HabitsBloc, HabitsState>(
      'HabitDeletionUndone восстанавливает привычку и отметки',
      build: buildBloc,
      seed: () => HabitsState(
        status: HabitsStatus.success,
        lastDeleted: habitA,
        lastDeletedEntries: [entryA],
      ),
      act: (bloc) => bloc.add(const HabitDeletionUndone()),
      expect: () => [const HabitsState(status: HabitsStatus.success)],
      verify: (_) {
        verify(() => repository.saveHabit(habitA)).called(1);
        verify(() => repository.restoreEntries([entryA])).called(1);
      },
    );
  });
}
