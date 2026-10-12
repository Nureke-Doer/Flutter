import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../../core/error/failures.dart';
import '../../../domain/entities/book.dart';
import '../../../domain/repositories/materials_repository.dart';

part 'materials_event.dart';
part 'materials_state.dart';

/// Debounce + restartable: ждём паузу в наборе текста, а если пришёл
/// новый запрос, предыдущий результат отбрасывается.
EventTransformer<E> debounceRestartable<E>(Duration duration) {
  return (events, mapper) =>
      restartable<E>().call(events.debounce(duration), mapper);
}

/// BLoC поиска учебных материалов: поиск с debounce, пагинация,
/// pull-to-refresh и состояния loading / success / empty / failure.
class MaterialsBloc extends Bloc<MaterialsEvent, MaterialsState> {
  MaterialsBloc({
    required MaterialsRepository repository,
    Duration debounce = const Duration(milliseconds: 400),
  }) : _repository = repository,
       super(MaterialsState(recentQueries: repository.recentQueries())) {
    on<MaterialsQueryChanged>(
      _onQueryChanged,
      transformer: debounceRestartable(debounce),
    );
    // droppable — пока страница грузится, повторные запросы игнорируются.
    on<MaterialsNextPageRequested>(_onNextPage, transformer: droppable());
    on<MaterialsRefreshed>(_onRefreshed, transformer: restartable());
    on<MaterialsHistoryCleared>(_onHistoryCleared);
  }

  final MaterialsRepository _repository;

  Future<void> _onQueryChanged(
    MaterialsQueryChanged event,
    Emitter<MaterialsState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(MaterialsState(recentQueries: _repository.recentQueries()));
      return;
    }
    if (query == state.query && state.status == MaterialsStatus.success) {
      return;
    }
    emit(MaterialsState(status: MaterialsStatus.loading, query: query));
    await _loadFirstPage(query, emit);
  }

  Future<void> _onRefreshed(
    MaterialsRefreshed event,
    Emitter<MaterialsState> emit,
  ) async {
    if (state.query.isEmpty) return;
    if (state.status == MaterialsStatus.failure) {
      emit(state.copyWith(status: MaterialsStatus.loading));
    } else {
      emit(state.copyWith(isRefreshing: true));
    }
    await _loadFirstPage(state.query, emit);
  }

  Future<void> _loadFirstPage(
    String query,
    Emitter<MaterialsState> emit,
  ) async {
    try {
      final result = await _repository.searchBooks(query);
      emit(
        MaterialsState(
          status: result.books.isEmpty
              ? MaterialsStatus.empty
              : MaterialsStatus.success,
          query: query,
          books: result.books,
          page: result.page,
          hasMore: result.hasMore,
          cachedAt: result.cachedAt,
        ),
      );
    } on Failure catch (failure) {
      emit(
        MaterialsState(
          status: MaterialsStatus.failure,
          query: query,
          failure: failure,
        ),
      );
    }
  }

  Future<void> _onHistoryCleared(
    MaterialsHistoryCleared event,
    Emitter<MaterialsState> emit,
  ) async {
    await _repository.clearRecentQueries();
    emit(state.copyWith(recentQueries: const []));
  }

  Future<void> _onNextPage(
    MaterialsNextPageRequested event,
    Emitter<MaterialsState> emit,
  ) async {
    if (state.status != MaterialsStatus.success ||
        !state.hasMore ||
        state.isLoadingMore) {
      return;
    }
    emit(state.copyWith(isLoadingMore: true, loadMoreFailed: false));
    try {
      final result = await _repository.searchBooks(
        state.query,
        page: state.page + 1,
      );
      emit(
        state.copyWith(
          books: [...state.books, ...result.books],
          page: result.page,
          hasMore: result.hasMore && result.books.isNotEmpty,
          isLoadingMore: false,
          cachedAt: () => result.cachedAt ?? state.cachedAt,
        ),
      );
    } on Failure {
      emit(state.copyWith(isLoadingMore: false, loadMoreFailed: true));
    }
  }
}
