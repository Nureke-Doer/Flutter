import 'dart:async';

import 'package:habit_study_tracker/core/error/failures.dart';
import 'package:habit_study_tracker/domain/entities/app_settings.dart';
import 'package:habit_study_tracker/domain/entities/app_user.dart';
import 'package:habit_study_tracker/domain/entities/book.dart';
import 'package:habit_study_tracker/domain/entities/category.dart';
import 'package:habit_study_tracker/domain/entities/metric.dart';
import 'package:habit_study_tracker/domain/entities/quote.dart';
import 'package:habit_study_tracker/domain/entities/study_goal.dart';
import 'package:habit_study_tracker/domain/repositories/auth_repository.dart';
import 'package:habit_study_tracker/domain/repositories/category_repository.dart';
import 'package:habit_study_tracker/domain/repositories/favorites_repository.dart';
import 'package:habit_study_tracker/domain/repositories/goal_repository.dart';
import 'package:habit_study_tracker/domain/repositories/materials_repository.dart';
import 'package:habit_study_tracker/domain/repositories/metric_repository.dart';
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
      settings = settings.copyWith(languageCode: languageCode);

  @override
  Future<void> saveThemePreference(ThemePreference preference) async =>
      settings = settings.copyWith(themePreference: preference);

  @override
  Future<void> saveGamificationEnabled(bool enabled) async =>
      settings = settings.copyWith(gamificationEnabled: enabled);

  @override
  Future<void> saveDailySummaryMinutes(int? minutes) async =>
      settings = settings.copyWith(dailySummaryMinutes: () => minutes);
}

/// Категории в памяти.
class FakeCategoryRepository implements CategoryRepository {
  FakeCategoryRepository([List<Category> initial = const []])
    : _items = List.of(initial);

  List<Category> _items;
  final _controller = StreamController<List<Category>>.broadcast();

  List<Category> get _sorted =>
      List.of(_items)..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  @override
  Stream<List<Category>> watchCategories() async* {
    yield _sorted;
    yield* _controller.stream;
  }

  @override
  Future<void> saveCategory(Category category) async {
    _items = [..._items.where((c) => c.id != category.id), category];
    _controller.add(_sorted);
  }

  @override
  Future<void> deleteCategory(String id) async {
    _items = _items.where((c) => c.id != id).toList();
    _controller.add(_sorted);
  }

  @override
  Future<void> reorder(List<String> orderedIds) async {
    _items = [
      for (final c in _items) c.copyWith(sortOrder: orderedIds.indexOf(c.id)),
    ];
    _controller.add(_sorted);
  }
}

/// Учебные цели в памяти.
class FakeGoalRepository implements GoalRepository {
  FakeGoalRepository([List<StudyGoal> initial = const []])
    : _items = List.of(initial);

  List<StudyGoal> _items;
  final _controller = StreamController<List<StudyGoal>>.broadcast();

  @override
  Stream<List<StudyGoal>> watchGoals() async* {
    yield List.of(_items);
    yield* _controller.stream;
  }

  @override
  Future<void> saveGoal(StudyGoal goal) async {
    final i = _items.indexWhere((g) => g.id == goal.id);
    _items = [..._items];
    i == -1 ? _items.add(goal) : _items[i] = goal;
    _controller.add(List.of(_items));
  }

  @override
  Future<void> deleteGoal(String id) async {
    _items = _items.where((g) => g.id != id).toList();
    _controller.add(List.of(_items));
  }
}

/// Авторизация в памяти. По умолчанию пользователь уже вошёл как гость.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    AppUser? user = const AppUser.guest(),
    this.accounts = true,
  }) : _user = user;

  AppUser? _user;
  final bool accounts;
  final _controller = StreamController<AppUser?>.broadcast();

  /// Пароль, с которым «сервер» принимает вход.
  static const password = 'secret1';

  @override
  AppUser? get currentUser => _user;

  @override
  Stream<AppUser?> authStateChanges() async* {
    yield _user;
    yield* _controller.stream;
  }

  @override
  bool get supportsAccounts => accounts;

  void _set(AppUser? user) {
    _user = user;
    _controller.add(user);
  }

  @override
  Future<void> signInWithEmail(String email, String password) async {
    if (!accounts) throw const AuthFailure(AuthErrorCode.unavailable);
    if (password != FakeAuthRepository.password) {
      throw const AuthFailure(AuthErrorCode.wrongCredentials);
    }
    _set(AppUser(uid: 'u1', email: email));
  }

  @override
  Future<void> registerWithEmail(
    String email,
    String password, {
    String? displayName,
  }) async {
    if (!accounts) throw const AuthFailure(AuthErrorCode.unavailable);
    _set(AppUser(uid: 'u1', email: email, displayName: displayName));
  }

  @override
  Future<void> signInWithGoogle() async {
    if (!accounts) throw const AuthFailure(AuthErrorCode.unavailable);
    _set(const AppUser(uid: 'g1', email: 'user@gmail.com'));
  }

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> continueAsGuest() async => _set(const AppUser.guest());

  @override
  Future<void> signOut() async => _set(null);
}

/// Метрики и связи в памяти.
class FakeMetricRepository implements MetricRepository {
  FakeMetricRepository({
    List<Metric> metrics = const [],
    List<HabitMetricRule> rules = const [],
  }) : _metrics = List.of(metrics),
       _rules = List.of(rules);

  List<Metric> _metrics;
  List<HabitMetricRule> _rules;
  final _metricsController = StreamController<List<Metric>>.broadcast();
  final _rulesController = StreamController<List<HabitMetricRule>>.broadcast();

  @override
  Stream<List<Metric>> watchMetrics() async* {
    yield List.of(_metrics);
    yield* _metricsController.stream;
  }

  @override
  Stream<List<HabitMetricRule>> watchRules() async* {
    yield List.of(_rules);
    yield* _rulesController.stream;
  }

  @override
  Future<void> saveMetric(Metric metric) async {
    _metrics = [..._metrics.where((m) => m.id != metric.id), metric];
    _metricsController.add(List.of(_metrics));
  }

  @override
  Future<void> deleteMetric(String id) async {
    _metrics = _metrics.where((m) => m.id != id).toList();
    _rules = _rules.where((r) => r.metricId != id).toList();
    _metricsController.add(List.of(_metrics));
    _rulesController.add(List.of(_rules));
  }

  @override
  Future<void> setRulesForHabit(
    String habitId,
    List<HabitMetricRule> rules,
  ) async {
    _rules = [..._rules.where((r) => r.habitId != habitId), ...rules];
    _rulesController.add(List.of(_rules));
  }
}
