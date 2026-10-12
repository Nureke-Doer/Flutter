import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/book.dart';
import '../../l10n/generated/app_localizations.dart';
import '../blocs/favorites/favorites_cubit.dart';

/// Кнопка-закладка «Сохранить / убрать из сохранённых».
class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // select — перестраиваемся только когда меняется статус этой книги.
    final saved = context.select(
      (FavoritesCubit cubit) => cubit.state.contains(book.id),
    );
    return IconButton(
      tooltip: saved ? l10n.removeFromSaved : l10n.addToSaved,
      isSelected: saved,
      icon: const Icon(Icons.bookmark_border),
      selectedIcon: Icon(
        Icons.bookmark,
        color: Theme.of(context).colorScheme.primary,
      ),
      onPressed: () => context.read<FavoritesCubit>().toggle(book),
    );
  }
}
