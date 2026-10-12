import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/number_utils.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/study_goal.dart';
import '../../l10n/generated/app_localizations.dart';
import '../blocs/favorites/favorites_cubit.dart';
import '../blocs/goals/goals_cubit.dart';
import '../blocs/habits/habits_bloc.dart';
import '../widgets/habit_visuals.dart';

/// Создание / редактирование учебной цели.
class GoalEditScreen extends StatefulWidget {
  const GoalEditScreen({super.key, this.initial});

  final StudyGoal? initial;

  @override
  State<GoalEditScreen> createState() => _GoalEditScreenState();
}

class _GoalEditScreenState extends State<GoalEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.initial?.title);
  late final _description = TextEditingController(
    text: widget.initial?.description,
  );
  late final _target = TextEditingController(
    text: widget.initial == null ? '' : formatInput(widget.initial!.target),
  );
  late final _unit = TextEditingController(text: widget.initial?.unit);
  late DateTime _deadline =
      widget.initial?.deadline ?? addDays(dateOnly(DateTime.now()), 30);
  late final Set<String> _linked = {...?widget.initial?.linkedHabitIds};
  late String? _bookTitle = widget.initial?.bookTitle;
  late int? _bookCoverId = widget.initial?.bookCoverId;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _target.dispose();
    _unit.dispose();
    super.dispose();
  }

  double? _parseTarget() => parseNumber(_target.text);

  Future<void> _pickDeadline() async {
    final today = dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline.isBefore(today) ? today : _deadline,
      firstDate: today.isBefore(_deadline) ? today : _deadline,
      lastDate: DateTime(today.year + 5),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final base =
        widget.initial ??
        StudyGoal(
          id: 'goal_${DateTime.now().microsecondsSinceEpoch}',
          title: '',
          target: 1,
          deadline: _deadline,
          createdAt: dateOnly(DateTime.now()),
        );
    final goal = base.copyWith(
      title: _title.text.trim(),
      description: _description.text.trim(),
      target: _parseTarget(),
      unit: _unit.text.trim(),
      deadline: _deadline,
      linkedHabitIds: {..._linked},
      bookTitle: () => _bookTitle,
      bookCoverId: () => _bookCoverId,
    );
    final router = GoRouter.of(context);
    await context.read<GoalsCubit>().save(goal);
    router.pop();
  }

  void _pickBook(Book? book) => setState(() {
    _bookTitle = book?.title;
    _bookCoverId = book?.coverId;
    if (book != null && _title.text.trim().isEmpty) {
      _title.text = book.title;
    }
    if (book?.pages != null && _target.text.trim().isEmpty) {
      _target.text = '${book!.pages}';
      if (_unit.text.trim().isEmpty) _unit.text = 'стр.';
    }
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final habits = context.select((HabitsBloc b) => b.state.activeHabits);
    final saved = context.select((FavoritesCubit c) => c.state.books);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initial == null ? l10n.goalNew : l10n.goalEdit),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Gaps.m),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    key: const Key('goalTitle'),
                    controller: _title,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: l10n.editFieldTitle,
                      hintText: l10n.goalTitleHint,
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l10n.editFieldTitleError
                        : null,
                  ),
                  const SizedBox(height: Gaps.m),
                  TextFormField(
                    controller: _description,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: l10n.editFieldDescription,
                    ),
                  ),
                  const SizedBox(height: Gaps.m),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          key: const Key('goalTarget'),
                          controller: _target,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: l10n.goalTarget,
                          ),
                          validator: (_) {
                            final t = _parseTarget();
                            return t == null || t <= 0
                                ? l10n.editTargetError
                                : null;
                          },
                        ),
                      ),
                      const SizedBox(width: Gaps.s),
                      Expanded(
                        child: TextFormField(
                          key: const Key('goalUnit'),
                          controller: _unit,
                          decoration: InputDecoration(
                            labelText: l10n.editUnit,
                            hintText: l10n.editUnitHint,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Gaps.m),
                  Card(
                    child: ListTile(
                      key: const Key('goalDeadline'),
                      leading: const Icon(Icons.event),
                      title: Text(l10n.goalDeadlineLabel),
                      subtitle: Text(
                        DateFormat.yMMMMd(locale).format(_deadline),
                      ),
                      onTap: _pickDeadline,
                    ),
                  ),
                  const SizedBox(height: Gaps.l),
                  Text(
                    l10n.goalLinkedHabits,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: Gaps.xs),
                  Text(
                    l10n.goalLinkedHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: Gaps.s),
                  Wrap(
                    spacing: Gaps.s,
                    runSpacing: Gaps.s,
                    children: [
                      for (final h in habits)
                        FilterChip(
                          avatar: Icon(h.icon.iconData, size: 18),
                          label: Text(h.title),
                          selected: _linked.contains(h.id),
                          onSelected: (on) => setState(
                            () => on ? _linked.add(h.id) : _linked.remove(h.id),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: Gaps.l),
                  Text(l10n.goalBook, style: theme.textTheme.titleSmall),
                  const SizedBox(height: Gaps.s),
                  if (saved.isEmpty && _bookTitle == null)
                    Text(
                      l10n.goalBookHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                  else
                    DropdownButtonFormField<String?>(
                      initialValue: _bookTitle,
                      isExpanded: true,
                      items: [
                        DropdownMenuItem(child: Text(l10n.goalNoBook)),
                        if (_bookTitle != null &&
                            !saved.any((b) => b.title == _bookTitle))
                          DropdownMenuItem(
                            value: _bookTitle,
                            child: Text(_bookTitle!),
                          ),
                        for (final b in saved)
                          DropdownMenuItem(
                            value: b.title,
                            child: Text(
                              b.title,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: (title) => _pickBook(
                        title == null
                            ? null
                            : saved.firstWhere(
                                (b) => b.title == title,
                                orElse: () => Book(
                                  id: '',
                                  title: title,
                                  coverId: _bookCoverId,
                                ),
                              ),
                      ),
                    ),
                  const SizedBox(height: Gaps.l),
                  FilledButton.icon(
                    key: const Key('goalSave'),
                    onPressed: _save,
                    icon: const Icon(Icons.check),
                    label: Text(l10n.save),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
