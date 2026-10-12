import 'package:flutter/material.dart';

import '../../domain/entities/book.dart';

/// Обложка книги из сети с индикатором загрузки и заглушкой при ошибке.
class BookCover extends StatelessWidget {
  const BookCover({
    super.key,
    required this.book,
    this.width = 56,
    this.size = 'M',
  });

  final Book book;
  final double width;

  /// Размер изображения Open Library: S, M или L.
  final String size;

  @override
  Widget build(BuildContext context) {
    final url = book.coverUrl(size);
    final height = width * 1.5;
    final scheme = Theme.of(context).colorScheme;
    final placeholder = Container(
      width: width,
      height: height,
      color: scheme.surfaceContainerHighest,
      child: Icon(
        Icons.menu_book_outlined,
        color: scheme.outline,
        size: width * 0.45,
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: url == null
          ? placeholder
          : Image.network(
              url,
              width: width,
              height: height,
              fit: BoxFit.cover,
              // Уменьшаем декодируемую картинку до размера на экране — экономия памяти.
              cacheWidth: (width * MediaQuery.devicePixelRatioOf(context))
                  .round(),
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : placeholder,
              errorBuilder: (_, _, _) => placeholder,
            ),
    );
  }
}
