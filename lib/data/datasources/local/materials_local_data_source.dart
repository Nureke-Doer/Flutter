import 'dart:convert';

import 'package:hive_ce/hive.dart';

import '../../models/book_dto.dart';
import '../../models/quote_dto.dart';

/// Запись кэша: данные и время сохранения.
class CachedEntry<T> {
  const CachedEntry(this.data, this.savedAt);

  final T data;
  final DateTime savedAt;
}

/// Локальный источник данных для учебных материалов (Hive):
/// кэш ответов API, цитата дня и история поиска.
class MaterialsLocalDataSource {
  MaterialsLocalDataSource({
    required Box<String> cacheBox,
    required Box<String> metaBox,
  }) : _cache = cacheBox,
       _meta = metaBox;

  static const maxRecentQueries = 8;
  static const _recentKey = 'recent_queries';
  static const _quoteKey = 'quote_of_day';

  final Box<String> _cache;
  final Box<String> _meta;

  static String _searchKey(String query, int page) =>
      'search:${query.trim().toLowerCase()}:$page';

  // ---------- Кэш поиска ----------

  Future<void> saveSearch(
    String query,
    int page,
    BookSearchResponseDto dto, {
    DateTime? now,
  }) => _put(_searchKey(query, page), dto.toJson(), now);

  CachedEntry<BookSearchResponseDto>? getSearch(String query, int page) =>
      _get(_searchKey(query, page), BookSearchResponseDto.fromJson);

  // ---------- Цитата дня ----------

  Future<void> saveQuote(QuoteDto dto, {DateTime? now}) =>
      _put(_quoteKey, dto.toJson(), now);

  CachedEntry<QuoteDto>? getQuote() => _get(_quoteKey, QuoteDto.fromJson);

  // ---------- История поиска ----------

  List<String> recentQueries() {
    final raw = _meta.get(_recentKey);
    if (raw == null) return const [];
    return (jsonDecode(raw) as List).cast<String>();
  }

  Future<void> addRecentQuery(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    final updated = [
      q,
      ...recentQueries().where((e) => e.toLowerCase() != q.toLowerCase()),
    ].take(maxRecentQueries).toList();
    await _meta.put(_recentKey, jsonEncode(updated));
  }

  Future<void> clearRecentQueries() => _meta.delete(_recentKey);

  Future<void> clearCache() => _cache.clear();

  // ---------- Вспомогательное ----------

  Future<void> _put(String key, Map<String, dynamic> data, DateTime? now) {
    return _cache.put(
      key,
      jsonEncode({
        'savedAt': (now ?? DateTime.now()).toIso8601String(),
        'data': data,
      }),
    );
  }

  CachedEntry<T>? _get<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final raw = _cache.get(key);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return CachedEntry(
        fromJson(map['data'] as Map<String, dynamic>),
        DateTime.parse(map['savedAt'] as String),
      );
    } on Object {
      return null; // повреждённый кэш просто игнорируем
    }
  }
}
