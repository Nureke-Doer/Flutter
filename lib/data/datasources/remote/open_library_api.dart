import 'package:dio/dio.dart';

import '../../models/book_dto.dart';

/// Удалённый источник данных: публичный API Open Library (без ключа).
/// Документация: https://openlibrary.org/dev/docs/api/search
class OpenLibraryApi {
  OpenLibraryApi(this._dio);

  static const baseUrl = 'https://openlibrary.org';
  static const pageSize = 20;

  /// Запрашиваем только нужные поля — ответ меньше и быстрее.
  static const _fields =
      'key,title,author_name,first_publish_year,cover_i,'
      'number_of_pages_median,edition_count,subject';

  final Dio _dio;

  Future<BookSearchResponseDto> search(
    String query, {
    int page = 1,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$baseUrl/search.json',
      queryParameters: {
        'q': query,
        'page': page,
        'limit': pageSize,
        'fields': _fields,
      },
      cancelToken: cancelToken,
    );
    return BookSearchResponseDto.fromJson(response.data ?? const {});
  }
}
