import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_study_tracker/core/error/failures.dart';
import 'package:habit_study_tracker/presentation/blocs/materials/materials_bloc.dart';

import '../helpers/fakes.dart';

void main() {
  late FakeMaterialsRepository repository;
  const debounce = Duration(milliseconds: 50);
  const wait = Duration(milliseconds: 120);

  setUp(() => repository = FakeMaterialsRepository(totalFound: 25));

  MaterialsBloc build() =>
      MaterialsBloc(repository: repository, debounce: debounce);

  blocTest<MaterialsBloc, MaterialsState>(
    'debounce: из нескольких быстрых вводов выполняется один запрос',
    build: build,
    act: (bloc) async {
      bloc
        ..add(const MaterialsQueryChanged('f'))
        ..add(const MaterialsQueryChanged('fl'))
        ..add(const MaterialsQueryChanged('flutter'));
    },
    wait: wait,
    expect: () => [
      const MaterialsState(status: MaterialsStatus.loading, query: 'flutter'),
      isA<MaterialsState>()
          .having((s) => s.status, 'status', MaterialsStatus.success)
          .having((s) => s.books.length, 'books', 20)
          .having((s) => s.hasMore, 'hasMore', true),
    ],
    verify: (_) => expect(repository.requests, ['flutter#1']),
  );

  blocTest<MaterialsBloc, MaterialsState>(
    'пустой результат даёт состояние empty',
    setUp: () => repository.totalFound = 0,
    build: build,
    act: (bloc) => bloc.add(const MaterialsQueryChanged('zzz')),
    wait: wait,
    expect: () => [
      const MaterialsState(status: MaterialsStatus.loading, query: 'zzz'),
      const MaterialsState(
        status: MaterialsStatus.empty,
        query: 'zzz',
        page: 1,
      ),
    ],
  );

  blocTest<MaterialsBloc, MaterialsState>(
    'ошибка сети даёт состояние failure',
    setUp: () => repository.failure = const NetworkFailure(),
    build: build,
    act: (bloc) => bloc.add(const MaterialsQueryChanged('dart')),
    wait: wait,
    expect: () => [
      const MaterialsState(status: MaterialsStatus.loading, query: 'dart'),
      const MaterialsState(
        status: MaterialsStatus.failure,
        query: 'dart',
        failure: NetworkFailure(),
      ),
    ],
  );

  blocTest<MaterialsBloc, MaterialsState>(
    'пустая строка сбрасывает поиск',
    build: build,
    seed: () =>
        const MaterialsState(status: MaterialsStatus.success, query: 'x'),
    act: (bloc) => bloc.add(const MaterialsQueryChanged('   ')),
    wait: wait,
    expect: () => [const MaterialsState()],
  );

  blocTest<MaterialsBloc, MaterialsState>(
    'следующая страница добавляется к списку',
    build: build,
    seed: () => MaterialsState(
      status: MaterialsStatus.success,
      query: 'q',
      books: [for (var i = 1; i <= 20; i++) testBook(i)],
      page: 1,
      hasMore: true,
    ),
    act: (bloc) => bloc
      ..add(const MaterialsNextPageRequested())
      ..add(
        const MaterialsNextPageRequested(),
      ), // второй отбрасывается (droppable)
    expect: () => [
      isA<MaterialsState>().having((s) => s.isLoadingMore, 'loadingMore', true),
      isA<MaterialsState>()
          .having((s) => s.books.length, 'books', 25)
          .having((s) => s.page, 'page', 2)
          .having((s) => s.hasMore, 'hasMore', false)
          .having((s) => s.isLoadingMore, 'loadingMore', false),
    ],
    verify: (_) => expect(repository.requests, ['q#2']),
  );

  blocTest<MaterialsBloc, MaterialsState>(
    'ошибка подгрузки сохраняет уже загруженные книги',
    setUp: () => repository.failure = const TimeoutFailure(),
    build: build,
    seed: () => MaterialsState(
      status: MaterialsStatus.success,
      query: 'q',
      books: [testBook(1)],
      page: 1,
      hasMore: true,
    ),
    act: (bloc) => bloc.add(const MaterialsNextPageRequested()),
    expect: () => [
      isA<MaterialsState>().having((s) => s.isLoadingMore, 'loadingMore', true),
      isA<MaterialsState>()
          .having((s) => s.loadMoreFailed, 'failed', true)
          .having((s) => s.books.length, 'books', 1),
    ],
  );

  blocTest<MaterialsBloc, MaterialsState>(
    'refresh перезагружает первую страницу',
    build: build,
    seed: () => MaterialsState(
      status: MaterialsStatus.success,
      query: 'q',
      books: [testBook(99)],
      page: 1,
    ),
    act: (bloc) => bloc.add(const MaterialsRefreshed()),
    expect: () => [
      isA<MaterialsState>().having((s) => s.isRefreshing, 'refreshing', true),
      isA<MaterialsState>()
          .having((s) => s.isRefreshing, 'refreshing', false)
          .having((s) => s.books.first, 'first', testBook(1)),
    ],
  );
}
