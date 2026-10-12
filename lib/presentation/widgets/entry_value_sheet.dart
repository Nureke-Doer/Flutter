import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/number_utils.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_entry.dart';
import '../../l10n/generated/app_localizations.dart';
import 'habit_visuals.dart';
import 'metrics_strip.dart';

/// Результат выбора в [showEntryValueSheet]: новое значение или «очистить».
class EntrySelection {
  const EntrySelection(this.value);

  /// `null` — очистить день («пусто»).
  final EntryValue? value;
}

/// Нижний лист для отметки дня: ✔ / ✘ / 0 (пропуск) / число / очистить.
///
/// Возвращает `null`, если пользователь закрыл лист без выбора.
Future<EntrySelection?> showEntryValueSheet(
  BuildContext context, {
  required Habit habit,
  required DateTime day,
  EntryValue? current,
}) {
  return showModalBottomSheet<EntrySelection>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) =>
        _EntryValueSheet(habit: habit, day: day, current: current),
  );
}

class _EntryValueSheet extends StatefulWidget {
  const _EntryValueSheet({
    required this.habit,
    required this.day,
    this.current,
  });

  final Habit habit;
  final DateTime day;
  final EntryValue? current;

  @override
  State<_EntryValueSheet> createState() => _EntryValueSheetState();
}

class _EntryValueSheetState extends State<_EntryValueSheet> {
  late final TextEditingController _amount = TextEditingController(
    text: switch (widget.current) {
      EntryAmount(:final amount) when amount > 0 => formatInput(amount),
      _ => '',
    },
  );

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  void _pick(EntryValue? value) =>
      Navigator.of(context).pop(EntrySelection(value));

  void _submitAmount() {
    final parsed = parseNumber(_amount.text);
    if (parsed == null || parsed < 0) return;
    // Число 0 по ТЗ — пропуск: ни на что не влияет.
    _pick(parsed == 0 ? const EntrySkipped() : EntryAmount(parsed));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final habit = widget.habit;
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Padding(
      // Поднимаем лист над клавиатурой.
      padding: EdgeInsets.fromLTRB(
        Gaps.m,
        0,
        Gaps.m,
        Gaps.m + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(habit.title, style: theme.textTheme.titleLarge),
          Text(
            DateFormat.MMMMEEEEd(locale).format(widget.day),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Gaps.m),
          if (habit.isNumeric) ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('amountField'),
                    controller: _amount,
                    autofocus: true,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.entryAmountLabel,
                      suffixText: habit.unit,
                      helperText: habit.target == null
                          ? null
                          : l10n.entryTargetHint(
                              formatAmount(habit.target!, habit.unit),
                            ),
                    ),
                    onSubmitted: (_) => _submitAmount(),
                  ),
                ),
                const SizedBox(width: Gaps.s),
                FilledButton(
                  key: const Key('amountSave'),
                  onPressed: _submitAmount,
                  child: Text(l10n.save),
                ),
              ],
            ),
            const SizedBox(height: Gaps.m),
          ],
          Wrap(
            spacing: Gaps.s,
            runSpacing: Gaps.s,
            children: [
              if (!habit.isNumeric)
                _ValueChip(
                  key: const Key('entryDone'),
                  icon: Icons.check,
                  label: habit.doneLabel(l10n),
                  color: habit.color,
                  selected: widget.current is EntryDone,
                  onTap: () => _pick(const EntryDone()),
                ),
              _ValueChip(
                key: const Key('entryFailed'),
                icon: Icons.close,
                label: habit.failedLabel(l10n),
                color: EntryColors.failed,
                selected: widget.current is EntryFailed,
                onTap: () => _pick(const EntryFailed()),
              ),
              _ValueChip(
                key: const Key('entrySkipped'),
                icon: Icons.exposure_zero,
                label: l10n.entrySkipped,
                color: theme.colorScheme.outline,
                selected: widget.current is EntrySkipped,
                onTap: () => _pick(const EntrySkipped()),
              ),
              if (widget.current != null)
                _ValueChip(
                  key: const Key('entryClear'),
                  icon: Icons.backspace_outlined,
                  label: l10n.entryClear,
                  color: theme.colorScheme.outline,
                  selected: false,
                  onTap: () => _pick(null),
                ),
            ],
          ),
          // Плашка метрик на экране отметки дня (если модуль включён).
          MetricsStrip(day: widget.day, navigable: false),
          const SizedBox(height: Gaps.s),
          Text(
            l10n.entrySkipHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ValueChip extends StatelessWidget {
  const _ValueChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      avatar: Icon(icon, color: selected ? Colors.white : color),
      label: Text(label),
      selected: selected,
      selectedColor: color,
      labelStyle: selected ? const TextStyle(color: Colors.white) : null,
      showCheckmark: false,
      onSelected: (_) => onTap(),
    );
  }
}
