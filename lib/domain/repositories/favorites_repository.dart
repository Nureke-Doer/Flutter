import '../entities/book.dart';

/// Избранные (сохранённые) учебные материалы — доступны без интернета.
abstract interface class FavoritesRepository {
  /// Поток со списком избранного; сразу отдаёт текущее значение.
  Stream<List<Book>> watchFavorites();

  /// Добавляет книгу в избранное или убирает, если она уже там.
  Future<void> toggleFavorite(Book book);
}
