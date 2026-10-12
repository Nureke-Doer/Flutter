import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../domain/entities/habit.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/habit_visuals.dart';

/// Создание новой цели или редактирование существующей.
///
/// Это `StatefulWidget`: экран хранит состояние формы
/// (выбранный тип, иконку, цвет, дни недели) и перерисовывается через `setState`.
/// При сохранении экран закрывается и возвращает готовый [Habit].
class HabitEditScreen extends StatefulWidget {
  const HabitEditScreen({super.key, this.initial});

  /// Цель для редактирования; `null` — создаём новую.
  final Habit? initial;

  @override
  State<HabitEditScreen> createState() => _HabitEditScreenState();
}

class _HabitEditScreenState extends State<HabitEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  late HabitType _type;
  late HabitIcon _icon;
  late int _colorValue;
  late Set<int> _weekdays;
  int? _reminderMinutes;
  int _targetMinutes = 30;
  bool _daysError = false;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final h = widget.initial;
    _titleController = TextEditingController(text: h?.title ?? '');
    _descriptionController = TextEditingController(text: h?.description ?? '');
    _type = h?.type ?? HabitType.habit;
    _icon = h?.icon ?? HabitIcon.check;
    _colorValue = h?.colorValue ?? habitPalette.first;
    _weekdays = {...(h?.weekdays ?? Habit.allWeekdays)};
    _reminderMinutes = h?.reminderMinutes;
    _targetMinutes = h?.targetMinutes ?? 30;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickReminder() async {
    final initial = _reminderMinutes ?? 9 * 60;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initial ~/ 60, minute: initial % 60),
    );
    if (picked != null) {
      setState(() => _reminderMinutes = picked.hour * 60 + picked.minute);
    }
  }

  void _save() {
    final formValid = _formKey.currentState!.validate();
    setState(() => _daysError = _weekdays.isEmpty);
    if (!formValid || _daysError) return;

    final base =
        widget.initial ??
        Habit(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: '',
          createdAt: DateTime.now(),
        );
    final habit = base.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      type: _type,
      icon: _icon,
      colorValue: _colorValue,
      weekdays: _weekdays,
      reminderMinutes: () => _reminderMinutes,
      targetMinutes: () => _type == HabitType.study ? _targetMinutes : null,
    );
    Navigator.of(context).pop(habit);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editEditTitle : l10n.editNewTitle),
      ),
      body: Form(
        key: _formKey,
        // SingleChildScrollView + Column, а не ListView: ListView удаляет
        // невидимые поля, и Form не смог бы их провалидировать.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Gaps.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                key: const Key('titleField'),
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.editFieldTitle,
                  hintText: l10n.editFieldTitleHint,
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? l10n.editFieldTitleError
                    : null,
              ),
              const SizedBox(height: Gaps.m),
              TextFormField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: l10n.editFieldDescription,
                ),
              ),
              _Label(l10n.editType),
              SegmentedButton<HabitType>(
                segments: [
                  for (final type in HabitType.values)
                    ButtonSegment(
                      value: type,
                      icon: Icon(type.iconData),
                      label: Text(type.label(l10n)),
                    ),
                ],
                selected: {_type},
                onSelectionChanged: (s) => setState(() => _type = s.first),
              ),
              if (_type == HabitType.study) ...[
                _Label(l10n.editTargetMinutes(_targetMinutes)),
                Slider(
                  value: _targetMinutes.toDouble(),
                  min: 5,
                  max: 180,
                  divisions: 35,
                  label: l10n.minutesShort(_targetMinutes),
                  onChanged: (v) => setState(() => _targetMinutes = v.round()),
                ),
              ],
              _Label(l10n.editIcon),
              Wrap(
                spacing: Gaps.s,
                runSpacing: Gaps.s,
                children: [
                  for (final icon in HabitIcon.values)
                    ChoiceChip(
                      showCheckmark: false,
                      label: Icon(icon.iconData, size: 22),
                      selected: icon == _icon,
                      onSelected: (_) => setState(() => _icon = icon),
                    ),
                ],
              ),
              _Label(l10n.editColor),
              Wrap(
                spacing: Gaps.s + 4,
                runSpacing: Gaps.s,
                children: [
                  for (final value in habitPalette)
                    GestureDetector(
                      onTap: () => setState(() => _colorValue = value),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(value),
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 3,
                            color: value == _colorValue
                                ? theme.colorScheme.onSurface
                                : Colors.transparent,
                          ),
                        ),
                        child: value == _colorValue
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    ),
                ],
              ),
              _Label(l10n.editDays),
              Wrap(
                spacing: Gaps.xs + 2,
                runSpacing: Gaps.xs,
                children: [
                  for (var wd = 1; wd <= 7; wd++)
                    FilterChip(
                      showCheckmark: false,
                      label: Text(weekdayShort(context, wd)),
                      selected: _weekdays.contains(wd),
                      onSelected: (selected) => setState(() {
                        selected ? _weekdays.add(wd) : _weekdays.remove(wd);
                        _daysError = false;
                      }),
                    ),
                ],
              ),
              if (_daysError)
                Padding(
                  padding: const EdgeInsets.only(top: Gaps.s),
                  child: Text(
                    l10n.editDaysError,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              const SizedBox(height: Gaps.m),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: Text(l10n.editReminder),
                  subtitle: Text(
                    _reminderMinutes == null
                        ? l10n.editReminderOff
                        : formatMinutes(context, _reminderMinutes!),
                  ),
                  trailing: Switch(
                    value: _reminderMinutes != null,
                    onChanged: (on) => on
                        ? _pickReminder()
                        : setState(() => _reminderMinutes = null),
                  ),
                  onTap: _pickReminder,
                ),
              ),
              const SizedBox(height: Gaps.l),
              FilledButton.icon(
                key: const Key('saveButton'),
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
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Gaps.l, bottom: Gaps.s),
      child: Text(text, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}
