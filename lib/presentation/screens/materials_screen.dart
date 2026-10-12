import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injection.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../blocs/materials/materials_bloc.dart';
import '../widgets/book_tile.dart';
import '../widgets/empty_state.dart';
import '../widgets/failure_message.dart';
import 'book_details_screen.dart';

/// Экран поиска учебных материалов (REST API Open Library).
class MaterialsScreen extends StatelessWidget {
  const MaterialsScreen({super.key, this.initialQuery});

  /// Запрос, с которого начинается поиск (например, название учебной цели).
  final String? initialQuery;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = getIt<MaterialsBloc>();
        if (initialQuery != null) {
          bloc.add(MaterialsQueryChanged(initialQuery!));
        }
        return bloc;
      },
      child: _MaterialsView(initialQuery: initialQuery),
    );
  }
}

class _MaterialsView extends StatefulWidget {
  const _MaterialsView({this.initialQuery});

  final String? initialQuery;

  @override
  State<_MaterialsView> createState() => _MaterialsViewState();
}

class _MaterialsViewState extends State<_MaterialsView> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialQuery,
  );
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Бесконечная прокрутка: за 300 px до конца просим следующую страницу.
  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      context.read<MaterialsBloc>().add(const MaterialsNextPageRequested());
    }
  }

  void _search(String query) {
    context.read<MaterialsBloc>().add(MaterialsQueryChanged(query));
  }

  void _useSuggestion(String query) {
    _controller.text = query;
    _search(query);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.materialsTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Gaps.m, 0, Gaps.m, Gaps.s),
            child: ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, value, _) => SearchBar(
                key: const Key('materialsSearch'),
                controller: _controller,
                hintText: l10n.materialsSearchHint,
                leading: const Icon(Icons.search),
                elevation: const WidgetStatePropertyAll(0),
                onChanged: _search,
                onSubmitted: _search,
                trailing: [
                  if (value.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        _search('');
                      },
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<MaterialsBloc, MaterialsState>(
              builder: (context, state) => switch (state.status) {
                MaterialsStatus.initial => _Suggestions(onTap: _useSuggestion),
                MaterialsStatus.loading => const Center(
                  child: CircularProgressIndicator(),
                ),
                MaterialsStatus.empty => EmptyState(
                  icon: Icons.search_off,
                  title: l10n.materialsEmpty(state.query),
                  message: l10n.materialsEmptyHint,
                ),
                MaterialsStatus.failure => EmptyState(
                  icon: Icons.cloud_off,
                  title: failureMessage(l10n, state.failure),
                  action: FilledButton.icon(
                    onPressed: () => context.read<MaterialsBloc>().add(
                      const MaterialsRefreshed(),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.retry),
                  ),
                ),
                MaterialsStatus.success => _ResultsList(
                  state: state,
                  controller: _scrollController,
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultsList extends StatelessWidget {
  const _ResultsList({required this.state, required this.controller});

  final MaterialsState state;
  final ScrollController controller;

  Future<void> _refresh(BuildContext context) async {
    final bloc = context.read<MaterialsBloc>()..add(const MaterialsRefreshed());
    // Ждём, пока BLoC закончит обновление, чтобы индикатор скрылся вовремя.
    await bloc.stream.firstWhere((s) => !s.isRefreshing);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final books = state.books;
    final showFooter = state.hasMore || state.loadMoreFailed;

    return RefreshIndicator(
      onRefresh: () => _refresh(context),
      // ListView.builder строит только видимые элементы — список
      // может быть длинным без потери производительности.
      child: ListView.builder(
        controller: controller,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(Gaps.m, 0, Gaps.m, Gaps.l),
        itemCount: books.length + 1 + (showFooter ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: Gaps.s, left: Gaps.xs),
              child: Text(
                l10n.materialsFound(books.length),
                style: Theme.of(context).textTheme.labelMedium,
              ),
            );
          }
          final i = index - 1;
          if (i >= books.length) {
            return Padding(
              padding: const EdgeInsets.all(Gaps.m),
              child: Center(
                child: state.loadMoreFailed
                    ? TextButton.icon(
                        onPressed: () => context.read<MaterialsBloc>().add(
                          const MaterialsNextPageRequested(),
                        ),
                        icon: const Icon(Icons.refresh),
                        label: Text(l10n.materialsLoadMoreError),
                      )
                    : const CircularProgressIndicator(),
              ),
            );
          }
          final book = books[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: Gaps.s),
            child: BookTile(
              book: book,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => BookDetailsScreen(book: book),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Suggestions extends StatelessWidget {
  const _Suggestions({required this.onTap});

  final ValueChanged<String> onTap;

  static const _topics = [
    'Flutter',
    'Algorithms',
    'English grammar',
    'Mathematics',
    'Physics',
    'Python',
    'History',
    'Psychology',
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(Gaps.m),
      children: [
        Icon(
          Icons.auto_stories_outlined,
          size: 64,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: Gaps.m),
        Text(
          l10n.materialsIntro,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: Gaps.l),
        Text(l10n.materialsSuggestions, style: theme.textTheme.titleSmall),
        const SizedBox(height: Gaps.s),
        Wrap(
          spacing: Gaps.s,
          runSpacing: Gaps.s,
          children: [
            for (final topic in _topics)
              ActionChip(
                avatar: const Icon(Icons.search, size: 18),
                label: Text(topic),
                onPressed: () => onTap(topic),
              ),
          ],
        ),
      ],
    );
  }
}
