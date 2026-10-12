import 'package:equatable/equatable.dart';

/// Учебный материал (книга) из каталога Open Library.
class Book extends Equatable {
  const Book({
    required this.id,
    required this.title,
    this.authors = const [],
    this.firstPublishYear,
    this.coverId,
    this.pages,
    this.editionCount,
    this.subjects = const [],
  });

  /// Ключ работы в Open Library, например `/works/OL45804W`.
  final String id;
  final String title;
  final List<String> authors;
  final int? firstPublishYear;
  final int? coverId;
  final int? pages;
  final int? editionCount;
  final List<String> subjects;

  String get authorsLabel => authors.join(', ');

  /// Ссылка на обложку. Размер: `S`, `M` или `L`.
  String? coverUrl([String size = 'M']) => coverId == null
      ? null
      : 'https://covers.openlibrary.org/b/id/$coverId-$size.jpg';

  /// Страница книги на сайте Open Library.
  String get webUrl => 'https://openlibrary.org$id';

  @override
  List<Object?> get props => [
    id,
    title,
    authors,
    firstPublishYear,
    coverId,
    pages,
    editionCount,
    subjects,
  ];
}

/// Страница результатов поиска (для пагинации).
class BookPage extends Equatable {
  const BookPage({
    required this.books,
    required this.page,
    required this.totalFound,
    required this.pageSize,
    this.cachedAt,
  });

  final List<Book> books;
  final int page;
  final int totalFound;
  final int pageSize;

  /// Если страница взята из локального кэша (нет сети) — когда она была сохранена.
  final DateTime? cachedAt;

  bool get fromCache => cachedAt != null;

  bool get hasMore => page * pageSize < totalFound;

  @override
  List<Object?> get props => [books, page, totalFound, pageSize, cachedAt];
}
