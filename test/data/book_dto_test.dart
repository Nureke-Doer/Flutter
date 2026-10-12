import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:habit_study_tracker/data/models/book_dto.dart';
import 'package:habit_study_tracker/data/models/quote_dto.dart';

void main() {
  late Map<String, dynamic> json;

  setUpAll(() {
    json =
        jsonDecode(
              File('test/fixtures/open_library_search.json').readAsStringSync(),
            )
            as Map<String, dynamic>;
  });

  test('BookSearchResponseDto разбирает ответ Open Library', () {
    final dto = BookSearchResponseDto.fromJson(json);
    expect(dto.numFound, 42);
    expect(dto.docs, hasLength(3));
    expect(dto.docs.first.authorName, [
      'Thomas H. Cormen',
      'Charles E. Leiserson',
    ]);
    expect(dto.docs.first.coverI, 8739161);
  });

  test('toEntity заполняет поля и обрабатывает отсутствующие', () {
    final dto = BookSearchResponseDto.fromJson(json);
    final full = dto.docs[0].toEntity();
    expect(full.title, 'Introduction to Algorithms');
    expect(full.pages, 1180);
    expect(
      full.coverUrl('S'),
      'https://covers.openlibrary.org/b/id/8739161-S.jpg',
    );
    expect(full.webUrl, 'https://openlibrary.org/works/OL1968368W');

    final minimal = dto.docs[2].toEntity();
    expect(minimal.title, '—');
    expect(minimal.authors, isEmpty);
    expect(minimal.coverUrl(), isNull);
  });

  test('пустой ответ даёт значения по умолчанию', () {
    final dto = BookSearchResponseDto.fromJson(const {});
    expect(dto.numFound, 0);
    expect(dto.docs, isEmpty);
  });

  test('toJson → fromJson сохраняет данные', () {
    final dto = BookSearchResponseDto.fromJson(json);
    final copy = BookSearchResponseDto.fromJson(
      jsonDecode(jsonEncode(dto.toJson())) as Map<String, dynamic>,
    );
    expect(copy.docs.first.toEntity(), dto.docs.first.toEntity());
  });

  test('QuoteDto разбирает ответ DummyJSON', () {
    final quote = QuoteDto.fromJson(const {
      'id': 7,
      'quote': 'Stay hungry, stay foolish.',
      'author': 'Steve Jobs',
    }).toEntity();
    expect(quote.text, 'Stay hungry, stay foolish.');
    expect(quote.author, 'Steve Jobs');
  });
}
