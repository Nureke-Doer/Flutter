import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/book.dart';

part 'book_dto.g.dart';

/// DTO (Data Transfer Object) — объект в точности как в JSON от Open Library.
/// Код `fromJson` / `toJson` генерируется пакетом json_serializable:
/// `dart run build_runner build --delete-conflicting-outputs`.
@JsonSerializable(fieldRename: FieldRename.snake)
class BookDto {
  const BookDto({
    required this.key,
    this.title,
    this.authorName,
    this.firstPublishYear,
    this.coverI,
    this.numberOfPagesMedian,
    this.editionCount,
    this.subject,
  });

  factory BookDto.fromJson(Map<String, dynamic> json) =>
      _$BookDtoFromJson(json);

  final String key;
  final String? title;
  final List<String>? authorName;
  final int? firstPublishYear;
  final int? coverI;
  final int? numberOfPagesMedian;
  final int? editionCount;
  final List<String>? subject;

  Map<String, dynamic> toJson() => _$BookDtoToJson(this);

  /// Преобразование в доменную сущность.
  Book toEntity() => Book(
    id: key,
    title: (title == null || title!.trim().isEmpty) ? '—' : title!.trim(),
    authors: authorName ?? const [],
    firstPublishYear: firstPublishYear,
    coverId: coverI,
    pages: numberOfPagesMedian,
    editionCount: editionCount,
    subjects: (subject ?? const []).take(8).toList(),
  );
}

/// Ответ `GET /search.json`.
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class BookSearchResponseDto {
  const BookSearchResponseDto({
    required this.numFound,
    required this.docs,
    this.start = 0,
  });

  factory BookSearchResponseDto.fromJson(Map<String, dynamic> json) =>
      _$BookSearchResponseDtoFromJson(json);

  @JsonKey(defaultValue: 0)
  final int numFound;
  @JsonKey(defaultValue: 0)
  final int start;
  @JsonKey(defaultValue: <BookDto>[])
  final List<BookDto> docs;

  Map<String, dynamic> toJson() => _$BookSearchResponseDtoToJson(this);
}
