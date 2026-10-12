import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_study_tracker/core/error/failures.dart';
import 'package:habit_study_tracker/data/datasources/remote/open_library_api.dart';
import 'package:habit_study_tracker/data/datasources/remote/quotes_api.dart';
import 'package:habit_study_tracker/data/repositories/materials_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late MaterialsRepositoryImpl repository;
  final requestOptions = RequestOptions(path: '/search.json');

  setUp(() {
    dio = MockDio();
    repository = MaterialsRepositoryImpl(
      booksApi: OpenLibraryApi(dio),
      quotesApi: QuotesApi(dio),
    );
  });

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
    final json =
        jsonDecode(
              File('test/fixtures/open_library_search.json').readAsStringSync(),
            )
            as Map<String, dynamic>;
    stubGet(
      () async =>
          Response(data: json, statusCode: 200, requestOptions: requestOptions),
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

  test('getRandomQuote возвращает цитату', () async {
    when(() => dio.get<Map<String, dynamic>>(any())).thenAnswer(
      (_) async => Response(
        data: {'id': 1, 'quote': 'Q', 'author': 'A'},
        statusCode: 200,
        requestOptions: requestOptions,
      ),
    );
    final quote = await repository.getRandomQuote();
    expect(quote.text, 'Q');
  });
}
