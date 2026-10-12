import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/book.dart';
import '../../../domain/repositories/favorites_repository.dart';

final class FavoritesState extends Equatable {
  const FavoritesState({this.books = const [], this.loaded = false});

  final List<Book> books;
  final bool loaded;

  bool contains(String bookId) => books.any((b) => b.id == bookId);

  @override
  List<Object?> get props => [books, loaded];
}

/// Список сохранённых материалов. Подписывается на поток репозитория,
/// поэтому все экраны видят изменения сразу.
class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit({required FavoritesRepository repository})
    : _repository = repository,
      super(const FavoritesState()) {
    _subscription = _repository.watchFavorites().listen(
      (books) => emit(FavoritesState(books: books, loaded: true)),
    );
  }

  final FavoritesRepository _repository;
  late final StreamSubscription<List<Book>> _subscription;

  Future<void> toggle(Book book) => _repository.toggleFavorite(book);

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
