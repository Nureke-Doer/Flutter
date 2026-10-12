import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_study_tracker/domain/entities/habit.dart';
import 'package:habit_study_tracker/domain/repositories/habit_repository.dart';
import 'package:habit_study_tracker/presentation/blocs/habits/habits_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockHabitRepository extends Mock implements HabitRepository {}

void main() {
  final day = DateTime(2026, 9, 9);
  final habitA = Habit(id: 'a', title: 'A', createdAt: day);
  final habitB = Habit(id: 'b', title: 'B', createdAt: day);

  late MockHabitRepository repository;

  setUpAll(() => registerFallbackValue(habitA));

  setUp(() {
    repository = MockHabitRepository();
    when(
      () => repository.watchHabits(),
    ).thenAnswer((_) => Stream.value([habitA, habitB]));
    when(() => repository.saveHabit(any())).thenAnswer((_) async {});
    when(() => repository.deleteHabit(any())).thenAnswer((_) async {});
  });

  HabitsBloc buildBloc() => HabitsBloc(repository: repository);

  test('начальное состояние — initial и пустой список', () {
    expect(buildBloc().state, const HabitsState());
  });

  group('HabitsSubscriptionRequested', () {
    blocTest<HabitsBloc, HabitsState>(
      'выдаёт loading, затем success с данными репозитория',
      build: buildBloc,
      act: (bloc) => bloc.add(const HabitsSubscriptionRequested()),
      expect: () => [
        const HabitsState(status: HabitsStatus.loading),
        HabitsState(status: HabitsStatus.success, habits: [habitA, habitB]),
      ],
    );

    blocTest<HabitsBloc, HabitsState>(
      'выдаёт failure при ошибке потока',
      setUp: () => when(
        () => repository.watchHabits(),
      ).thenAnswer((_) => Stream.error(Exception('oops'))),
      build: buildBloc,
      act: (bloc) => bloc.add(const HabitsSubscriptionRequested()),
      expect: () => [
        const HabitsState(status: HabitsStatus.loading),
        const HabitsState(status: HabitsStatus.failure),
      ],
    );
  });

  group('HabitToggled', () {
    blocTest<HabitsBloc, HabitsState>(
      'сохраняет цель с переключённой отметкой',
      build: buildBloc,
      seed: () =>
          HabitsState(status: HabitsStatus.success, habits: [habitA, habitB]),
      act: (bloc) => bloc.add(HabitToggled('a', day)),
      verify: (_) {
        final saved =
            verify(() => repository.saveHabit(captureAny())).captured.single
                as Habit;
        expect(saved.id, 'a');
        expect(saved.isCompletedOn(day), isTrue);
      },
    );

    blocTest<HabitsBloc, HabitsState>(
      'ничего не делает для неизвестной цели',
      build: buildBloc,
      seed: () => HabitsState(status: HabitsStatus.success, habits: [habitA]),
      act: (bloc) => bloc.add(HabitToggled('missing', day)),
      verify: (_) => verifyNever(() => repository.saveHabit(any())),
    );
  });

  blocTest<HabitsBloc, HabitsState>(
    'HabitSaved сохраняет цель в репозитории',
    build: buildBloc,
    act: (bloc) => bloc.add(HabitSaved(habitB)),
    verify: (_) => verify(() => repository.saveHabit(habitB)).called(1),
  );

  group('удаление', () {
    blocTest<HabitsBloc, HabitsState>(
      'HabitDeleted запоминает удалённую цель и удаляет её',
      build: buildBloc,
      seed: () => HabitsState(status: HabitsStatus.success, habits: [habitA]),
      act: (bloc) => bloc.add(const HabitDeleted('a')),
      expect: () => [
        HabitsState(
          status: HabitsStatus.success,
          habits: [habitA],
          lastDeleted: habitA,
        ),
      ],
      verify: (_) => verify(() => repository.deleteHabit('a')).called(1),
    );

    blocTest<HabitsBloc, HabitsState>(
      'HabitDeletionUndone восстанавливает цель',
      build: buildBloc,
      seed: () => HabitsState(
        status: HabitsStatus.success,
        habits: const [],
        lastDeleted: habitA,
      ),
      act: (bloc) => bloc.add(const HabitDeletionUndone()),
      expect: () => [
        const HabitsState(status: HabitsStatus.success, habits: []),
      ],
      verify: (_) => verify(() => repository.saveHabit(habitA)).called(1),
    );
  });
}
