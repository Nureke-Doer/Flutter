import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/category.dart';

part 'category_model.g.dart';

@JsonSerializable()
class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    this.sortOrder = 0,
    this.colorValue = 0xFF00897B,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  factory CategoryModel.fromEntity(Category c) => CategoryModel(
    id: c.id,
    name: c.name,
    sortOrder: c.sortOrder,
    colorValue: c.colorValue,
  );

  final String id;
  final String name;
  final int sortOrder;
  final int colorValue;

  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);

  Category toEntity() => Category(
    id: id,
    name: name,
    sortOrder: sortOrder,
    colorValue: colorValue,
  );
}
