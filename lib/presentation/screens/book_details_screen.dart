import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/book.dart';
import '../../l10n/generated/app_localizations.dart';
import '../widgets/book_cover.dart';
import '../widgets/favorite_button.dart';

/// Подробная информация об учебном материале.
class BookDetailsScreen extends StatelessWidget {
  const BookDetailsScreen({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(actions: [FavoriteButton(book: book)]),
      body: ListView(
        padding: const EdgeInsets.all(Gaps.m),
        children: [
          Center(
            child: Hero(
              tag: 'cover-${book.id}',
              child: BookCover(book: book, width: 160, size: 'L'),
            ),
          ),
          const SizedBox(height: Gaps.l),
          Text(
            book.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: Gaps.s),
          Text(
            book.authors.isEmpty ? l10n.bookUnknownAuthor : book.authorsLabel,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Gaps.l),
          Card(
            child: Column(
              children: [
                if (book.firstPublishYear != null)
                  ListTile(
                    leading: const Icon(Icons.event_outlined),
                    title: Text(l10n.bookYear),
                    trailing: Text('${book.firstPublishYear}'),
                  ),
                if (book.pages != null)
                  ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: Text(l10n.bookPages),
                    trailing: Text('${book.pages}'),
                  ),
                if (book.editionCount != null)
                  ListTile(
                    leading: const Icon(Icons.library_books_outlined),
                    title: Text(l10n.bookEditions),
                    trailing: Text('${book.editionCount}'),
                  ),
              ],
            ),
          ),
          if (book.subjects.isNotEmpty) ...[
            const SizedBox(height: Gaps.l),
            Text(l10n.bookSubjects, style: theme.textTheme.titleSmall),
            const SizedBox(height: Gaps.s),
            Wrap(
              spacing: Gaps.s,
              runSpacing: Gaps.s,
              children: [for (final s in book.subjects) Chip(label: Text(s))],
            ),
          ],
          const SizedBox(height: Gaps.l),
          Text(
            '${l10n.bookOpenLibrary}\n${book.webUrl}',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
