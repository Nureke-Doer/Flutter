import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/category.dart';
import '../../l10n/generated/app_localizations.dart';
import '../blocs/categories/categories_cubit.dart';
import '../blocs/habits/habits_bloc.dart';
import '../widgets/empty_state.dart';
import '../widgets/habit_visuals.dart';

/// Управление категориями: создать, переименовать, перетащить, удалить.
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  Future<void> _edit(BuildContext context, [Category? category]) async {
    final cubit = context.read<CategoriesCubit>();
    final result = await showDialog<(String, int)>(
      context: context,
      builder: (_) => _CategoryDialog(initial: category),
    );
    if (result == null) return;
    final (name, color) = result;
    if (category == null) {
      await cubit.create(name, colorValue: color);
    } else {
      await cubit.update(category.id, name: name, colorValue: color);
    }
  }

  Future<void> _delete(BuildContext context, Category category) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<CategoriesCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle(category.name)),
        content: Text(l10n.categoryDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) await cubit.delete(category.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categories = context.watch<CategoriesCubit>().state;
    final habits = context.select((HabitsBloc b) => b.state.habits);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.categoriesTitle)),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('addCategory'),
        heroTag: 'categoriesFab',
        onPressed: () => _edit(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.categoryAdd),
      ),
      body: categories.isEmpty
          ? EmptyState(icon: Icons.label_outline, title: l10n.categoriesEmpty)
          : ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(Gaps.m, Gaps.s, Gaps.m, 96),
              itemCount: categories.length,
              onReorderItem: context.read<CategoriesCubit>().move,
              header: Padding(
                padding: const EdgeInsets.only(bottom: Gaps.s),
                child: Text(
                  l10n.categoriesHint,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              itemBuilder: (context, i) {
                final c = categories[i];
                final count = habits.where((h) => h.categoryId == c.id).length;
                return Card(
                  key: ValueKey(c.id),
                  margin: const EdgeInsets.only(bottom: Gaps.s),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(c.colorValue),
                      radius: 12,
                    ),
                    title: Text(c.name),
                    subtitle: Text(l10n.habitsCount(count)),
                    onTap: () => _edit(context, c),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: l10n.delete,
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _delete(context, c),
                        ),
                        ReorderableDragStartListener(
                          index: i,
                          child: const Icon(Icons.drag_handle),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _CategoryDialog extends StatefulWidget {
  const _CategoryDialog({this.initial});

  final Category? initial;

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  late final _controller = TextEditingController(text: widget.initial?.name);
  late int _color = widget.initial?.colorValue ?? habitPalette.first;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    Navigator.pop(context, (name, _color));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.initial == null ? l10n.categoryAdd : l10n.edit),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const Key('categoryName'),
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: l10n.editFieldTitle),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: Gaps.m),
          Wrap(
            spacing: Gaps.s,
            runSpacing: Gaps.s,
            children: [
              for (final value in habitPalette)
                InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => setState(() => _color = value),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(value),
                    child: value == _color
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          key: const Key('categorySave'),
          onPressed: _submit,
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
