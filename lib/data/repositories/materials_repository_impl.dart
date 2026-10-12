import 'package:dio/dio.dart';

import '../../core/error/failures.dart';
import '../../core/network/dio_client.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/quote.dart';
import '../../domain/repositories/materials_repository.dart';
import '../datasources/remote/open_library_api.dart';
import '../datasources/remote/quotes_api.dart';

/// Реализация [MaterialsRepository] поверх REST API.
/// Отвечает за преобразование DTO → сущности и ошибок → [Failure].
class MaterialsRepositoryImpl implements MaterialsRepository {
  MaterialsRepositoryImpl({
    required OpenLibraryApi booksApi,
    required QuotesApi quotesApi,
  }) : _booksApi = booksApi,
       _quotesApi = quotesApi;

  final OpenLibraryApi _booksApi;
  final QuotesApi _quotesApi;

  @override
  Future<BookPage> searchBooks(String query, {int page = 1}) {
    return _guard(() async {
      final dto = await _booksApi.search(query, page: page);
      return BookPage(
        books: dto.docs.map((d) => d.toEntity()).toList(),
        page: page,
        totalFound: dto.numFound,
        pageSize: OpenLibraryApi.pageSize,
      );
    });
  }

  @override
  Future<Quote> getRandomQuote() {
    return _guard(() async => (await _quotesApi.random()).toEntity());
  }

  /// Выполняет запрос и переводит любые исключения в [Failure].
  Future<T> _guard<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw mapDioException(e);
    } on TypeError catch (e) {
      // Неверный тип поля в JSON (например, строка вместо числа).
      throw ParsingFailure(e.toString());
    } on FormatException catch (e) {
      throw ParsingFailure(e.message);
    }
  }
}
