part of 'materials_bloc.dart';

enum MaterialsStatus { initial, loading, success, empty, failure }

final class MaterialsState extends Equatable {
  const MaterialsState({
    this.status = MaterialsStatus.initial,
    this.query = '',
    this.books = const [],
    this.page = 0,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.loadMoreFailed = false,
    this.failure,
    this.cachedAt,
    this.recentQueries = const [],
  });

  final MaterialsStatus status;
  final String query;
  final List<Book> books;

  /// Номер последней загруженной страницы.
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isRefreshing;

  /// Не удалось загрузить следующую страницу (первые результаты остаются).
  final bool loadMoreFailed;
  final Failure? failure;

  /// Не `null`, если результаты показаны из кэша (нет сети).
  final DateTime? cachedAt;

  /// История поиска — показывается, пока запрос пустой.
  final List<String> recentQueries;

  bool get fromCache => cachedAt != null;

  MaterialsState copyWith({
    MaterialsStatus? status,
    String? query,
    List<Book>? books,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isRefreshing,
    bool? loadMoreFailed,
    Failure? Function()? failure,
    DateTime? Function()? cachedAt,
    List<String>? recentQueries,
  }) {
    return MaterialsState(
      status: status ?? this.status,
      query: query ?? this.query,
      books: books ?? this.books,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
      failure: failure != null ? failure() : this.failure,
      cachedAt: cachedAt != null ? cachedAt() : this.cachedAt,
      recentQueries: recentQueries ?? this.recentQueries,
    );
  }

  @override
  List<Object?> get props => [
    status,
    query,
    books,
    page,
    hasMore,
    isLoadingMore,
    isRefreshing,
    loadMoreFailed,
    failure,
    cachedAt,
    recentQueries,
  ];
}
