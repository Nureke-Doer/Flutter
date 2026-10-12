import 'package:equatable/equatable.dart';

/// Категория привычек («Учёба», «Спорт», «Здоровье», «Зависимости»…).
/// Пользователь сам создаёт, переименовывает, сортирует и удаляет категории.
class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    this.sortOrder = 0,
    this.colorValue = 0xFF00897B,
  });

  final String id;
  final String name;

  /// Позиция в списке (меньше — выше).
  final int sortOrder;
  final int colorValue;

  Category copyWith({String? name, int? sortOrder, int? colorValue}) =>
      Category(
        id: id,
        name: name ?? this.name,
        sortOrder: sortOrder ?? this.sortOrder,
        colorValue: colorValue ?? this.colorValue,
      );

  @override
  List<Object?> get props => [id, name, sortOrder, colorValue];
}
