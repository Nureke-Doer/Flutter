import 'package:dio/dio.dart';

import '../../core/error/failures.dart';
import '../../core/network/dio_client.dart';
import '../../core/utils/date_utils.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/quote.dart';
import '../../domain/repositories/materials_repository.dart';
import '../datasources/local/materials_local_data_source.dart';
import '../datasources/remote/open_library_api.dart';
import '../datasources/remote/quotes_api.dart';
import '../models/book_dto.dart';

/// Реализация [MaterialsRepository]: REST API + локальный кэш (Hive).
///
/// - Поиск: **network-first** — сначала сеть, ответ сохраняется в кэш;
///   если сети нет, отдаётся кэш с пометкой `cachedAt`.
/// - Цитата дня: **cache-first** — если сегодня цитата уже загружена,
///   сеть не используется; без сети отдаётся последняя сохранённая.
class MaterialsRepositoryImpl implements MaterialsRepository {
  MaterialsRepositoryImpl({
    required OpenLibraryApi booksApi,
    required QuotesApi quotesApi,
    required MaterialsLocalDataSource local,
    DateTime Function()? clock,
  }) : _booksApi = booksApi,
       _quotesApi = quotesApi,
       _local = local,
       _now = clock ?? DateTime.now;

  final OpenLibraryApi _booksApi;
  final QuotesApi _quotesApi;
  final MaterialsLocalDataSource _local;
  final DateTime Function() _now;

  @override
  Future<BookPage> searchBooks(String query, {int page = 1}) async {
    try {
      final dto = await _guard(() => _booksApi.search(query, page: page));
      await _local.saveSearch(query, page, dto, now: _now());
      if (page == 1) await _local.addRecentQuery(query);
      return _toPage(dto, page);
    } on Failure catch (failure) {
      if (_isOffline(failure)) {
        final cached = _local.getSearch(query, page);
        if (cached != null) {
          return _toPage(cached.data, page, cachedAt: cached.savedAt);
        }
      }
      rethrow;
    }
  }

  @override
  Future<Quote> getQuoteOfDay({bool forceRefresh = false}) async {
    final cached = _local.getQuote();
    if (!forceRefresh && cached != null && isSameDay(cached.savedAt, _now())) {
      return cached.data.toEntity();
    }
    try {
      final dto = await _guard(_quotesApi.random);
      await _local.saveQuote(dto, now: _now());
      return dto.toEntity();
    } on Failure {
      if (cached != null) return cached.data.toEntity();
      rethrow;
    }
  }

  @override
  List<String> recentQueries() => _local.recentQueries();

  @override
  Future<void> clearRecentQueries() => _local.clearRecentQueries();

  @override
  Future<void> clearCache() async {
    await _local.clearCache();
    await _local.clearRecentQueries();
  }

  BookPage _toPage(BookSearchResponseDto dto, int page, {DateTime? cachedAt}) {
    return BookPage(
      books: dto.docs.map((d) => d.toEntity()).toList(),
      page: page,
      totalFound: dto.numFound,
      pageSize: OpenLibraryApi.pageSize,
      cachedAt: cachedAt,
    );
  }

  static bool _isOffline(Failure f) =>
      f is NetworkFailure || f is TimeoutFailure;

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
