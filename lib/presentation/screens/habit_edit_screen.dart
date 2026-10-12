import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/number_utils.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/metric.dart';
import '../../l10n/generated/app_localizations.dart';
import '../blocs/categories/categories_cubit.dart';
import '../blocs/metrics/metrics_cubit.dart';
import '../providers/settings_notifier.dart';
import '../widgets/habit_visuals.dart';
import '../widgets/metric_visuals.dart';

/// Создание новой привычки или редактирование существующей.
///
/// Это `StatefulWidget`: экран хранит состояние формы
/// (тип, категорию, иконку, цвет, расписание) и перерисовывается через
/// `setState`. При сохранении экран закрывается и возвращает готовую [Habit].
class HabitEditScreen extends StatefulWidget {
  const HabitEditScreen({super.key, this.initial, this.initialCategoryId});

  /// Привычка для редактирования; `null` — создаём новую.
  final Habit? initial;

  /// Категория по умолчанию для новой привычки.
  final String? initialCategoryId;

  @override
  State<HabitEditScreen> createState() => _HabitEditScreenState();
}

class _HabitEditScreenState extends State<HabitEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _unitController;
  late final TextEditingController _targetController;

  late HabitKind _kind;
  String? _categoryId;
  late HabitIcon _icon;
  late int _colorValue;
  late ScheduleType _scheduleType;
  late Set<int> _weekdays;
  late int _timesPerWeek;
  int? _reminderMinutes;
  bool _daysError = false;

  /// Черновики связей «привычка → метрика» (только если геймификация включена).
  final Map<String, _RuleDraft> _rules = {};
  late final bool _gamification;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final h = widget.initial;
    _titleController = TextEditingController(text: h?.title ?? '');
    _descriptionController = TextEditingController(text: h?.description ?? '');
    _unitController = TextEditingController(text: h?.unit ?? '');
    _targetController = TextEditingController(
      text: h?.target == null ? '' : formatInput(h!.target!),
    );
    _kind = h?.kind ?? HabitKind.positive;
    _categoryId = h?.categoryId ?? widget.initialCategoryId;
    _icon = h?.icon ?? HabitIcon.check;
    _colorValue = h?.colorValue ?? habitPalette.first;
    final schedule = h?.schedule ?? const HabitSchedule.daily();
    _scheduleType = schedule.type;
    _weekdays = schedule.type == ScheduleType.weekdays
        ? {...schedule.weekdays}
        : {1, 2, 3, 4, 5};
    _timesPerWeek = schedule.type == ScheduleType.timesPerWeek
        ? schedule.timesPerWeek
        : 3;
    _reminderMinutes = h?.reminderMinutes;

    _gamification = context.read<SettingsNotifier>().gamificationEnabled;
    if (_gamification) {
      final metrics = context.read<MetricsCubit>().state;
      for (final m in metrics.metrics) {
        HabitMetricRule? existing;
        for (final r in metrics.rules) {
          if (r.habitId == h?.id && r.metricId == m.id) existing = r;
        }
        _rules[m.id] = _RuleDraft(
          metric: m,
          enabled: existing != null,
          reward: existing?.reward,
          penalty: existing?.penalty,
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _unitController.dispose();
    _targetController.dispose();
    for (final r in _rules.values) {
      r.dispose();
    }
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

  double? _parseTarget() => parseNumber(_targetController.text);

  HabitSchedule get _schedule => switch (_scheduleType) {
    ScheduleType.daily => const HabitSchedule.daily(),
    ScheduleType.weekdays => HabitSchedule.weekdays({..._weekdays}),
    ScheduleType.timesPerWeek => HabitSchedule.timesPerWeek(_timesPerWeek),
  };

  void _save() {
    final formValid = _formKey.currentState!.validate();
    setState(
      () => _daysError =
          _scheduleType == ScheduleType.weekdays && _weekdays.isEmpty,
    );
    if (!formValid || _daysError) return;

    final numeric = _kind == HabitKind.numeric;
    final unit = _unitController.text.trim();
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
      categoryId: () => _categoryId,
      kind: _kind,
      icon: _icon,
      colorValue: _colorValue,
      unit: () => numeric && unit.isNotEmpty ? unit : null,
      target: () => numeric ? _parseTarget() : null,
      schedule: _schedule,
      reminderMinutes: () => _reminderMinutes,
    );
    if (_gamification) {
      // Связь необязательна: пустой список — привычка не влияет на метрики.
      context.read<MetricsCubit>().setRulesForHabit(habit.id, [
        for (final d in _rules.values)
          if (d.enabled)
            HabitMetricRule(
              habitId: habit.id,
              metricId: d.metric.id,
              reward: d.parsedReward,
              penalty: d.parsedPenalty,
            ),
      ]);
    }
    Navigator.of(context).pop(habit);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final categories = context.watch<CategoriesCubit>().state;
    // Категория могла быть удалена — тогда «Без категории».
    final categoryValue = categories.any((c) => c.id == _categoryId)
        ? _categoryId
        : null;

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
          child: Center(
            // На планшете форма не растягивается на всю ширину.
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
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
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
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
                  const SizedBox(height: Gaps.m),
                  DropdownButtonFormField<String?>(
                    key: const Key('categoryField'),
                    initialValue: categoryValue,
                    decoration: InputDecoration(labelText: l10n.editCategory),
                    items: [
                      DropdownMenuItem(child: Text(l10n.noCategory)),
                      for (final c in categories)
                        DropdownMenuItem(value: c.id, child: Text(c.name)),
                    ],
                    onChanged: (id) => setState(() => _categoryId = id),
                  ),
                  _Label(l10n.editType),
                  SegmentedButton<HabitKind>(
                    key: const Key('kindSelector'),
                    showSelectedIcon: false,
                    segments: [
                      for (final kind in HabitKind.values)
                        ButtonSegment(
                          value: kind,
                          icon: Icon(kind.iconData),
                          label: Text(kind.label(l10n)),
                        ),
                    ],
                    selected: {_kind},
                    onSelectionChanged: (s) => setState(() => _kind = s.first),
                  ),
                  const SizedBox(height: Gaps.s),
                  Text(
                    _kind.hint(l10n),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (_kind == HabitKind.numeric) ...[
                    const SizedBox(height: Gaps.m),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            key: const Key('unitField'),
                            controller: _unitController,
                            decoration: InputDecoration(
                              labelText: l10n.editUnit,
                              hintText: l10n.editUnitHint,
                            ),
                          ),
                        ),
                        const SizedBox(width: Gaps.s),
                        Expanded(
                          child: TextFormField(
                            key: const Key('targetField'),
                            controller: _targetController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: l10n.editTarget,
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return null;
                              final t = _parseTarget();
                              return t == null || t <= 0
                                  ? l10n.editTargetError
                                  : null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                  _Label(l10n.editSchedule),
                  SegmentedButton<ScheduleType>(
                    key: const Key('scheduleSelector'),
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                        value: ScheduleType.daily,
                        label: Text(l10n.scheduleDaily),
                      ),
                      ButtonSegment(
                        value: ScheduleType.weekdays,
                        label: Text(l10n.scheduleWeekdays),
                      ),
                      ButtonSegment(
                        value: ScheduleType.timesPerWeek,
                        label: Text(l10n.scheduleTimesPerWeek),
                      ),
                    ],
                    selected: {_scheduleType},
                    onSelectionChanged: (s) => setState(() {
                      _scheduleType = s.first;
                      _daysError = false;
                    }),
                  ),
                  const SizedBox(height: Gaps.s),
                  if (_scheduleType == ScheduleType.weekdays)
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
                              selected
                                  ? _weekdays.add(wd)
                                  : _weekdays.remove(wd);
                              _daysError = false;
                            }),
                          ),
                      ],
                    ),
                  if (_scheduleType == ScheduleType.timesPerWeek) ...[
                    Text(l10n.timesPerWeek(_timesPerWeek)),
                    Slider(
                      value: _timesPerWeek.toDouble(),
                      min: 1,
                      max: 6,
                      divisions: 5,
                      label: '$_timesPerWeek',
                      onChanged: (v) =>
                          setState(() => _timesPerWeek = v.round()),
                    ),
                  ],
                  if (_daysError)
                    Padding(
                      padding: const EdgeInsets.only(top: Gaps.s),
                      child: Text(
                        l10n.editDaysError,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
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
                  if (_gamification) ...[
                    const SizedBox(height: Gaps.m),
                    _MetricRulesSection(
                      drafts: _rules.values.toList(),
                      onChanged: () => setState(() {}),
                    ),
                  ],
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

/// Черновик связи с метрикой: включена ли, награда за ✔ и штраф за ✘.
class _RuleDraft {
  _RuleDraft({
    required this.metric,
    required this.enabled,
    double? reward,
    double? penalty,
  }) : reward = TextEditingController(
         text: reward == null ? '' : formatInput(reward),
       ),
       penalty = TextEditingController(
         text: penalty == null ? '' : formatInput(penalty),
       );

  final Metric metric;
  bool enabled;
  final TextEditingController reward;
  final TextEditingController penalty;

  static double _parse(String text) => parseNumber(text)?.abs() ?? 0;

  double get parsedReward => _parse(reward.text);
  double get parsedPenalty => _parse(penalty.text);

  void dispose() {
    reward.dispose();
    penalty.dispose();
  }
}

/// Свёрнутый блок «Влияние на метрики» (виден, только если включена
/// геймификация). Привычка может влиять на любое число метрик или ни на одну.
class _MetricRulesSection extends StatelessWidget {
  const _MetricRulesSection({required this.drafts, required this.onChanged});

  final List<_RuleDraft> drafts;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final active = drafts.where((d) => d.enabled).length;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        key: const Key('metricRulesSection'),
        leading: const Icon(Icons.sports_esports_outlined),
        title: Text(l10n.habitMetricRules),
        subtitle: Text(l10n.habitMetricsCount(active)),
        childrenPadding: const EdgeInsets.fromLTRB(Gaps.m, 0, Gaps.m, Gaps.m),
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.metricLossHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (drafts.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: Gaps.s),
              child: Text(l10n.habitMetricRulesEmpty),
            ),
          for (final d in drafts) ...[
            SwitchListTile(
              key: Key('rule_${d.metric.id}'),
              contentPadding: EdgeInsets.zero,
              secondary: Icon(d.metric.icon.iconData),
              title: Text(d.metric.name),
              value: d.enabled,
              onChanged: (v) {
                d.enabled = v;
                onChanged();
              },
            ),
            if (d.enabled)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: Key('reward_${d.metric.id}'),
                      controller: d.reward,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: l10n.metricReward,
                        prefixText: '+',
                        suffixText: d.metric.unit,
                      ),
                    ),
                  ),
                  const SizedBox(width: Gaps.s),
                  Expanded(
                    child: TextField(
                      key: Key('penalty_${d.metric.id}'),
                      controller: d.penalty,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: l10n.metricPenalty,
                        prefixText: '−',
                        suffixText: d.metric.unit,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }
}
