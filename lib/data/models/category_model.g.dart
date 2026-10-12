// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryModel _$CategoryModelFromJson(Map<String, dynamic> json) =>
    CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      colorValue: (json['colorValue'] as num?)?.toInt() ?? 0xFF00897B,
    );

Map<String, dynamic> _$CategoryModelToJson(CategoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'sortOrder': instance.sortOrder,
      'colorValue': instance.colorValue,
    };
