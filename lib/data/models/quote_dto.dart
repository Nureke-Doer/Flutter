import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/quote.dart';

part 'quote_dto.g.dart';

/// Ответ `GET https://dummyjson.com/quotes/random`:
/// `{"id": 1, "quote": "...", "author": "..."}`.
@JsonSerializable()
class QuoteDto {
  const QuoteDto({required this.id, required this.quote, required this.author});

  factory QuoteDto.fromJson(Map<String, dynamic> json) =>
      _$QuoteDtoFromJson(json);

  final int id;
  final String quote;
  final String author;

  Map<String, dynamic> toJson() => _$QuoteDtoToJson(this);

  Quote toEntity() => Quote(text: quote, author: author);
}
