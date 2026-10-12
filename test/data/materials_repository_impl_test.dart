import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_study_tracker/core/error/failures.dart';
import 'package:habit_study_tracker/data/datasources/local/hive_storage.dart';
import 'package:habit_study_tracker/data/datasources/local/materials_local_data_source.dart';
import 'package:habit_study_tracker/data/datasources/remote/open_library_api.dart';
import 'package:habit_study_tracker/data/datasources/remote/quotes_api.dart';
import 'package:habit_study_tracker/data/repositories/materials_repository_impl.dart';
import 'package:hive_ce/hive.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/hive_test_utils.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late MaterialsLocalDataSource local;
  late MaterialsRepositoryImpl repository;
  var now = DateTime(2026, 9, 9, 10);
  final requestOptions = RequestOptions(path: '/search.json');

  late Map<String, dynamic> fixture;

  setUpAll(() {
    fixture =
        jsonDecode(
              File('test/fixtures/open_library_search.json').readAsStringSync(),
            )
            as Map<String, dynamic>;
  });

  setUp(() async {
    await setUpTestHive();
    dio = MockDio();
    now = DateTime(2026, 9, 9, 10);
    local = MaterialsLocalDataSource(
      cacheBox: Hive.box<String>(HiveBoxes.apiCache),
      metaBox: Hive.box<String>(HiveBoxes.meta),
    );
    repository = MaterialsRepositoryImpl(
      booksApi: OpenLibraryApi(dio),
      quotesApi: QuotesApi(dio),
      local: local,
      clock: () => now,
    );
  });

  tearDown(tearDownTestHive);

  DioException offline() => DioException(
    requestOptions: requestOptions,
    type: DioExceptionType.connectionError,
  );

  void stubGet(Future<Response<Map<String, dynamic>>> Function() answer) {
    when(
      () => dio.get<Map<String, dynamic>>(
        any(),
        queryParameters: any(named: 'queryParameters'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer((_) => answer());
  }

  test('searchBooks возвращает страницу книг и передаёт параметры', () async {
    stubGet(
      () async => Response(
        data: fixture,
        statusCode: 200,
        requestOptions: requestOptions,
      ),
    );

    final page = await repository.searchBooks('algorithms', page: 2);

    expect(page.books, hasLength(3));
    expect(page.page, 2);
    expect(page.totalFound, 42);
    expect(page.hasMore, isTrue); // 2 * 20 < 42

    final captured = verify(
      () => dio.get<Map<String, dynamic>>(
        captureAny(),
        queryParameters: captureAny(named: 'queryParameters'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).captured;
    expect(captured[0], 'https://openlibrary.org/search.json');
    expect((captured[1] as Map)['q'], 'algorithms');
    expect((captured[1] as Map)['page'], 2);
  });

  final cases = <DioExceptionType, Type>{
    DioExceptionType.connectionTimeout: TimeoutFailure,
    DioExceptionType.receiveTimeout: TimeoutFailure,
    DioExceptionType.connectionError: NetworkFailure,
    DioExceptionType.badResponse: ServerFailure,
  };
  cases.forEach((type, failureType) {
    test('$type превращается в $failureType', () async {
      stubGet(
        () => Future.error(
          DioException(
            requestOptions: requestOptions,
            type: type,
            response: Response(requestOptions: requestOptions, statusCode: 503),
          ),
        ),
      );
      await expectLater(
        repository.searchBooks('x'),
        throwsA(
          isA<Failure>().having((f) => f.runtimeType, 'type', failureType),
        ),
      );
    });
  });

  test('ServerFailure содержит код ответа', () async {
    stubGet(
      () => Future.error(
        DioException.badResponse(
          statusCode: 500,
          requestOptions: requestOptions,
          response: Response(requestOptions: requestOptions, statusCode: 500),
        ),
      ),
    );
    await expectLater(
      repository.searchBooks('x'),
      throwsA(isA<ServerFailure>().having((f) => f.statusCode, 'code', 500)),
    );
  });

  test('неверный тип поля в JSON даёт ParsingFailure', () async {
    stubGet(
      () async => Response(
        data: {'num_found': 'много', 'docs': []},
        statusCode: 200,
        requestOptions: requestOptions,
      ),
    );
    await expectLater(
      repository.searchBooks('x'),
      throwsA(isA<ParsingFailure>()),
    );
  });

  group('offline-first: поиск', () {
    test('успешный ответ сохраняется в кэш и историю', () async {
      stubGet(
        () async => Response(
          data: fixture,
          statusCode: 200,
          requestOptions: requestOptions,
        ),
      );
      final page = await repository.searchBooks('Algorithms');
      expect(page.fromCache, isFalse);
      expect(local.getSearch('algorithms', 1), isNotNull);
      expect(repository.recentQueries(), ['Algorithms']);
    });

    test('без сети возвращается кэш с датой сохранения', () async {
      stubGet(
        () async => Response(
          data: fixture,
          statusCode: 200,
          requestOptions: requestOptions,
        ),
      );
      await repository.searchBooks('algorithms');

      stubGet(() => Future.error(offline()));
      final page = await repository.searchBooks('algorithms');
      expect(page.fromCache, isTrue);
      expect(page.cachedAt, now);
      expect(page.books, hasLength(3));
    });

    test('без сети и без кэша — NetworkFailure', () async {
      stubGet(() => Future.error(offline()));
      await expectLater(
        repository.searchBooks('new'),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('ошибка сервера не подменяется кэшем', () async {
      stubGet(
        () async => Response(
          data: fixture,
          statusCode: 200,
          requestOptions: requestOptions,
        ),
      );
      await repository.searchBooks('algorithms');
      stubGet(
        () => Future.error(
          DioException.badResponse(
            statusCode: 500,
            requestOptions: requestOptions,
            response: Response(requestOptions: requestOptions, statusCode: 500),
          ),
        ),
      );
      await expectLater(
        repository.searchBooks('algorithms'),
        throwsA(isA<ServerFailure>()),
      );
    });

    test('clearCache удаляет кэш и историю', () async {
      stubGet(
        () async => Response(
          data: fixture,
          statusCode: 200,
          requestOptions: requestOptions,
        ),
      );
      await repository.searchBooks('algorithms');
      await repository.clearCache();
      expect(local.getSearch('algorithms', 1), isNull);
      expect(repository.recentQueries(), isEmpty);
    });
  });

  group('цитата дня (cache-first)', () {
    var calls = 0;

    setUp(() {
      calls = 0;
      when(() => dio.get<Map<String, dynamic>>(any())).thenAnswer((_) async {
        calls++;
        return Response(
          data: {'id': calls, 'quote': 'Q$calls', 'author': 'A'},
          statusCode: 200,
          requestOptions: requestOptions,
        );
      });
    });

    test('в течение дня берётся из кэша без запроса в сеть', () async {
      expect((await repository.getQuoteOfDay()).text, 'Q1');
      now = now.add(const Duration(hours: 5));
      expect((await repository.getQuoteOfDay()).text, 'Q1');
      expect(calls, 1);
    });

    test('на следующий день загружается новая', () async {
      await repository.getQuoteOfDay();
      now = now.add(const Duration(days: 1));
      expect((await repository.getQuoteOfDay()).text, 'Q2');
    });

    test('forceRefresh загружает новую', () async {
      await repository.getQuoteOfDay();
      expect((await repository.getQuoteOfDay(forceRefresh: true)).text, 'Q2');
    });

    test('без сети возвращается вчерашняя цитата', () async {
      await repository.getQuoteOfDay();
      now = now.add(const Duration(days: 1));
      when(
        () => dio.get<Map<String, dynamic>>(any()),
      ).thenAnswer((_) => Future.error(offline()));
      expect((await repository.getQuoteOfDay()).text, 'Q1');
    });

    test('без сети и без кэша — NetworkFailure', () async {
      when(
        () => dio.get<Map<String, dynamic>>(any()),
      ).thenAnswer((_) => Future.error(offline()));
      await expectLater(
        repository.getQuoteOfDay(),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });
}
