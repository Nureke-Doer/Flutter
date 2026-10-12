import 'package:habit_study_tracker/core/error/failures.dart';
import 'package:habit_study_tracker/domain/entities/book.dart';
import 'package:habit_study_tracker/domain/entities/quote.dart';
import 'package:habit_study_tracker/domain/repositories/materials_repository.dart';

/// Создаёт тестовую книгу.
Book testBook(int n) => Book(id: '/works/OL${n}W', title: 'Книга $n');

/// Простой фейковый репозиторий материалов для widget-тестов.
class FakeMaterialsRepository implements MaterialsRepository {
  FakeMaterialsRepository({
    this.totalFound = 3,
    this.failure,
    this.quote = const Quote(text: 'Учись каждый день', author: 'Автор'),
  });

  int totalFound;
  Failure? failure;
  Quote? quote;
  final List<String> requests = [];

  @override
  Future<BookPage> searchBooks(String query, {int page = 1}) async {
    requests.add('$query#$page');
    if (failure != null) throw failure!;
    const pageSize = 20;
    final start = (page - 1) * pageSize;
    final count = (totalFound - start).clamp(0, pageSize);
    return BookPage(
      books: [for (var i = 0; i < count; i++) testBook(start + i + 1)],
      page: page,
      totalFound: totalFound,
      pageSize: pageSize,
    );
  }

  @override
  Future<Quote> getRandomQuote() async {
    if (quote == null) throw const NetworkFailure();
    return quote!;
  }
}
