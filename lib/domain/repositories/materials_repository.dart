import '../entities/book.dart';
import '../entities/quote.dart';

/// Репозиторий учебных материалов и мотивационных цитат (данные из сети).
///
/// Методы бросают `Failure` (см. `core/error/failures.dart`) при ошибке.
abstract interface class MaterialsRepository {
  /// Поиск книг по запросу. [page] начинается с 1.
  Future<BookPage> searchBooks(String query, {int page = 1});

  /// Случайная мотивационная цитата.
  Future<Quote> getRandomQuote();
}
