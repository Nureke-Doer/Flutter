import '../entities/category.dart';

/// Категории привычек.
abstract interface class CategoryRepository {
  /// Категории, отсортированные по `sortOrder`.
  Stream<List<Category>> watchCategories();

  Future<void> saveCategory(Category category);

  /// Удаляет категорию. Её привычки не удаляются: привычка с
  /// несуществующей категорией показывается в «Без категории».
  Future<void> deleteCategory(String id);

  /// Сохраняет новый порядок: [orderedIds] — id категорий сверху вниз.
  Future<void> reorder(List<String> orderedIds);
}
