import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/local/local_collection.dart';
import '../models/category_model.dart';

/// Категории привычек в Hive.
class HiveCategoryRepository implements CategoryRepository {
  HiveCategoryRepository(this._collection);

  final LocalCollection _collection;

  static List<Category> _map(List<Map<String, dynamic>> raw) {
    final list = <Category>[];
    for (final json in raw) {
      try {
        list.add(CategoryModel.fromJson(json).toEntity());
      } on Object {
        continue;
      }
    }
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return List.unmodifiable(list);
  }

  @override
  Stream<List<Category>> watchCategories() => _collection.watch().map(_map);

  @override
  Future<void> saveCategory(Category category) =>
      _collection.put(category.id, CategoryModel.fromEntity(category).toJson());

  @override
  Future<void> deleteCategory(String id) => _collection.delete(id);

  @override
  Future<void> reorder(List<String> orderedIds) async {
    final current = {for (final c in _map(_collection.readAll())) c.id: c};
    await _collection.putAll({
      for (var i = 0; i < orderedIds.length; i++)
        if (current[orderedIds[i]] case final c?)
          c.id: CategoryModel.fromEntity(c.copyWith(sortOrder: i)).toJson(),
    });
  }
}
