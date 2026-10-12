// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuoteDto _$QuoteDtoFromJson(Map<String, dynamic> json) => QuoteDto(
  id: (json['id'] as num).toInt(),
  quote: json['quote'] as String,
  author: json['author'] as String,
);

Map<String, dynamic> _$QuoteDtoToJson(QuoteDto instance) => <String, dynamic>{
  'id': instance.id,
  'quote': instance.quote,
  'author': instance.author,
};
