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
  ];
}
