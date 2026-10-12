import '../entities/book.dart';
import '../entities/quote.dart';

/// Репозиторий учебных материалов и мотивационных цитат.
///
/// Стратегия offline-first: результаты из сети кэшируются локально,
/// а при отсутствии сети возвращается кэш (`BookPage.fromCache == true`).
/// Методы бросают `Failure` (см. `core/error/failures.dart`), если
/// нет ни сети, ни кэша.
abstract interface class MaterialsRepository {
  /// Поиск книг по запросу. [page] начинается с 1.
  Future<BookPage> searchBooks(String query, {int page = 1});

  /// Цитата дня. Загружается из сети не чаще раза в день;
  /// [forceRefresh] — загрузить новую принудительно.
  Future<Quote> getQuoteOfDay({bool forceRefresh = false});

  /// Последние поисковые запросы (новые — первыми).
  List<String> recentQueries();

  Future<void> clearRecentQueries();

  /// Удаляет кэш ответов API и историю поиска.
  Future<void> clearCache();
}
