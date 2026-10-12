import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/category.dart';
import '../../../domain/repositories/category_repository.dart';

/// Категории привычек: создание, переименование, сортировка, удаление.
///
/// Cubit (а не Bloc), потому что операции простые: UI вызывает методы,
/// а новый список приходит из потока репозитория.
class CategoriesCubit extends Cubit<List<Category>> {
  CategoriesCubit({required CategoryRepository repository})
    : _repository = repository,
      super(const []) {
    _subscription = _repository.watchCategories().listen(emit);
  }

  final CategoryRepository _repository;
  late final StreamSubscription<List<Category>> _subscription;

  Category? byId(String? id) {
    for (final c in state) {
      if (c.id == id) return c;
    }
    return null;
  }

  Future<void> create(String name, {int? colorValue}) {
    final nextOrder = state.isEmpty ? 0 : state.last.sortOrder + 1;
    return _repository.saveCategory(
      Category(
        id: 'cat_${DateTime.now().microsecondsSinceEpoch}',
        name: name.trim(),
        sortOrder: nextOrder,
        colorValue: colorValue ?? 0xFF00897B,
      ),
    );
  }

  /// Переименовать и/или сменить цвет.
  Future<void> update(String id, {String? name, int? colorValue}) async {
    final category = byId(id);
    if (category == null) return;
    await _repository.saveCategory(
      category.copyWith(name: name?.trim(), colorValue: colorValue),
    );
  }

  Future<void> delete(String id) => _repository.deleteCategory(id);

  /// Перемещение в списке (аргументы как у
  /// `ReorderableListView.onReorderItem`: [newIndex] — итоговая позиция).
  Future<void> move(int oldIndex, int newIndex) {
    final ids = state.map((c) => c.id).toList();
    ids.insert(newIndex, ids.removeAt(oldIndex));
    return _repository.reorder(ids);
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
