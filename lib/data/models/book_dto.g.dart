// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookDto _$BookDtoFromJson(Map<String, dynamic> json) => BookDto(
  key: json['key'] as String,
  title: json['title'] as String?,
  authorName: (json['author_name'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  firstPublishYear: (json['first_publish_year'] as num?)?.toInt(),
  coverI: (json['cover_i'] as num?)?.toInt(),
  numberOfPagesMedian: (json['number_of_pages_median'] as num?)?.toInt(),
  editionCount: (json['edition_count'] as num?)?.toInt(),
  subject: (json['subject'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$BookDtoToJson(BookDto instance) => <String, dynamic>{
  'key': instance.key,
  'title': instance.title,
  'author_name': instance.authorName,
  'first_publish_year': instance.firstPublishYear,
  'cover_i': instance.coverI,
  'number_of_pages_median': instance.numberOfPagesMedian,
  'edition_count': instance.editionCount,
  'subject': instance.subject,
};

BookSearchResponseDto _$BookSearchResponseDtoFromJson(
  Map<String, dynamic> json,
) => BookSearchResponseDto(
  numFound: (json['num_found'] as num?)?.toInt() ?? 0,
  docs:
      (json['docs'] as List<dynamic>?)
          ?.map((e) => BookDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  start: (json['start'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$BookSearchResponseDtoToJson(
  BookSearchResponseDto instance,
) => <String, dynamic>{
  'num_found': instance.numFound,
  'start': instance.start,
  'docs': instance.docs.map((e) => e.toJson()).toList(),
};
