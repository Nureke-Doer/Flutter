import 'dart:async';

import 'package:habit_study_tracker/core/error/failures.dart';
import 'package:habit_study_tracker/domain/entities/app_settings.dart';
import 'package:habit_study_tracker/domain/entities/book.dart';
import 'package:habit_study_tracker/domain/entities/quote.dart';
import 'package:habit_study_tracker/domain/repositories/favorites_repository.dart';
import 'package:habit_study_tracker/domain/repositories/materials_repository.dart';
import 'package:habit_study_tracker/domain/repositories/settings_repository.dart';

/// Создаёт тестовую книгу.
Book testBook(int n) => Book(id: '/works/OL${n}W', title: 'Книга $n');

/// Простой фейковый репозиторий материалов для тестов.
class FakeMaterialsRepository implements MaterialsRepository {
  FakeMaterialsRepository({
    this.totalFound = 3,
    this.failure,
    this.quote = const Quote(text: 'Учись каждый день', author: 'Автор'),
    this.cachedAt,
    List<String>? recent,
  }) : recent = recent ?? [];

  int totalFound;
  Failure? failure;
  Quote? quote;

  /// Если задано — результаты поиска помечаются как взятые из кэша.
  DateTime? cachedAt;
  List<String> recent;
  final List<String> requests = [];
  bool cacheCleared = false;

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
      cachedAt: cachedAt,
    );
  }

  @override
  Future<Quote> getQuoteOfDay({bool forceRefresh = false}) async {
    if (quote == null) throw const NetworkFailure();
    return quote!;
  }

  @override
  List<String> recentQueries() => List.of(recent);

  @override
  Future<void> clearRecentQueries() async => recent = [];

  @override
  Future<void> clearCache() async {
    cacheCleared = true;
    recent = [];
  }
}

/// Избранное в памяти.
class FakeFavoritesRepository implements FavoritesRepository {
  final _books = <Book>[];
  final _controller = StreamController<List<Book>>.broadcast();

  @override
  Stream<List<Book>> watchFavorites() async* {
    yield List.of(_books);
    yield* _controller.stream;
  }

  @override
  Future<void> toggleFavorite(Book book) async {
    if (!_books.remove(book)) _books.insert(0, book);
    _controller.add(List.of(_books));
  }
}

/// Настройки в памяти.
class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository([this.settings = const AppSettings()]);

  AppSettings settings;

  @override
  AppSettings load() => settings;

  @override
  Future<void> saveLanguageCode(String languageCode) async =>
      settings = AppSettings(
        themePreference: settings.themePreference,
        languageCode: languageCode,
      );

  @override
  Future<void> saveThemePreference(ThemePreference preference) async =>
      settings = AppSettings(
        themePreference: preference,
        languageCode: settings.languageCode,
      );
}
