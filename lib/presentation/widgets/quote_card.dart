import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../blocs/quote/quote_cubit.dart';

/// Карточка «Цитата дня». При ошибке сети просто скрывается —
/// это второстепенная информация, не мешаем пользователю.
class QuoteCard extends StatelessWidget {
  const QuoteCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return BlocBuilder<QuoteCubit, QuoteState>(
      builder: (context, state) {
        final quote = state.quote;
        if (quote == null) {
          if (state.status == QuoteStatus.loading) {
            return const Padding(
              padding: EdgeInsets.only(top: Gaps.s),
              child: LinearProgressIndicator(),
            );
          }
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(top: Gaps.s),
          child: Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => context.read<QuoteCubit>().load(forceRefresh: true),
              child: Padding(
                padding: const EdgeInsets.all(Gaps.m),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.format_quote, color: theme.colorScheme.primary),
                    const SizedBox(width: Gaps.s),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.quoteOfDay,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: Gaps.xs),
                          Text(
                            quote.text,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: Gaps.xs),
                          Text(
                            '— ${quote.author}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
