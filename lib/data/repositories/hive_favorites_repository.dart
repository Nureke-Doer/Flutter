import 'dart:convert';

import 'package:hive_ce/hive.dart';

import '../../domain/entities/book.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../models/book_dto.dart';

/// Избранные материалы в Hive. Книга сохраняется целиком (а не только id),
/// поэтому список доступен без интернета.
class HiveFavoritesRepository implements FavoritesRepository {
  HiveFavoritesRepository(this._box);

  final Box<String> _box;

  List<Book> _readAll() {
    final books = <Book>[];
    for (final raw in _box.values) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        books.add(BookDto.fromJson(map).toEntity());
      } on Object {
        continue;
      }
    }
    return List.unmodifiable(books.reversed); // новые — первыми
  }

  @override
  Stream<List<Book>> watchFavorites() async* {
    yield _readAll();
    yield* _box.watch().map((_) => _readAll());
  }

  @override
  Future<void> toggleFavorite(Book book) async {
    if (_box.containsKey(book.id)) {
      await _box.delete(book.id);
    } else {
      await _box.put(book.id, jsonEncode(BookDto.fromEntity(book).toJson()));
    }
  }
}
