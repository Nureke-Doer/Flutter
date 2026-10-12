import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/book.dart';
import '../../l10n/generated/app_localizations.dart';
import 'book_cover.dart';

/// Элемент списка учебных материалов.
class BookTile extends StatelessWidget {
  const BookTile({super.key, required this.book, this.onTap, this.trailing});

  final Book book;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final meta = [
      if (book.firstPublishYear != null) '${book.firstPublishYear}',
      if (book.pages != null) '${book.pages} ${l10n.bookPages.toLowerCase()}',
    ].join(' · ');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'cover-${book.id}',
                child: BookCover(book: book),
              ),
              const SizedBox(width: Gaps.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: Gaps.xs),
                    Text(
                      book.authors.isEmpty
                          ? l10n.bookUnknownAuthor
                          : book.authorsLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: Gaps.xs),
                      Text(meta, style: theme.textTheme.bodySmall),
                    ],
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}
