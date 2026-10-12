import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/number_utils.dart';
import '../../domain/entities/metric.dart';
import '../../l10n/generated/app_localizations.dart';
import '../blocs/metrics/metrics_cubit.dart';
import '../widgets/metric_visuals.dart';

/// Создание / редактирование метрики. Пресеты Power и Money заполняют
/// поля, но пользователь может создать любую свою метрику.
class MetricEditScreen extends StatefulWidget {
  const MetricEditScreen({super.key, this.initial});

  final Metric? initial;

  @override
  State<MetricEditScreen> createState() => _MetricEditScreenState();
}

class _MetricEditScreenState extends State<MetricEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial?.name);
  late final _unit = TextEditingController(text: widget.initial?.unit);
  late final _start = TextEditingController(
    text: formatInput(widget.initial?.startValue ?? 0),
  );
  late final _gain = TextEditingController(
    text: widget.initial == null
        ? ''
        : formatInput(widget.initial!.maxGainPerDay),
  );
  late final _loss = TextEditingController(
    text: widget.initial == null
        ? ''
        : formatInput(widget.initial!.maxLossPerDay),
  );
  late MetricIcon _icon = widget.initial?.icon ?? MetricIcon.star;
  late MetricMode _mode = widget.initial?.mode ?? MetricMode.absolute;

  @override
  void dispose() {
    for (final c in [_name, _unit, _start, _gain, _loss]) {
      c.dispose();
    }
    super.dispose();
  }

  static double? _parse(String text) => parseNumber(text);

  void _applyPreset(Metric preset) => setState(() {
    _name.text = preset.name;
    _unit.text = preset.unit;
    _start.text = formatInput(preset.startValue);
    _gain.text = formatInput(preset.maxGainPerDay);
    _loss.text = formatInput(preset.maxLossPerDay);
    _icon = preset.icon;
    _mode = preset.mode;
  });

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final cubit = context.read<MetricsCubit>();
    final router = GoRouter.of(context);
    final metric = Metric(
      id:
          widget.initial?.id ??
          'metric_${DateTime.now().microsecondsSinceEpoch}',
      name: _name.text.trim(),
      unit: _unit.text.trim(),
      icon: _icon,
      startValue: _parse(_start.text) ?? 0,
      maxGainPerDay: _parse(_gain.text)!,
      maxLossPerDay: _parse(_loss.text)!,
      mode: _mode,
      sortOrder: widget.initial?.sortOrder ?? cubit.state.metrics.length,
    );
    await cubit.saveMetric(metric);
    router.pop();
  }

  String? _positive(String? v, AppLocalizations l10n) {
    final n = _parse(v ?? '');
    return n == null || n <= 0 ? l10n.editTargetError : null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initial == null ? l10n.metricAdd : l10n.edit),
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
                  if (widget.initial == null) ...[
                    Text(l10n.metricPresets, style: theme.textTheme.titleSmall),
                    const SizedBox(height: Gaps.s),
                    Wrap(
                      spacing: Gaps.s,
                      children: [
                        ActionChip(
                          key: const Key('presetPower'),
                          avatar: Icon(MetricIcon.power.iconData, size: 18),
                          label: Text(l10n.metricPresetPower),
                          onPressed: () =>
                              _applyPreset(MetricPresets.power('')),
                        ),
                        ActionChip(
                          key: const Key('presetMoney'),
                          avatar: Icon(MetricIcon.money.iconData, size: 18),
                          label: Text(l10n.metricPresetMoney),
                          onPressed: () =>
                              _applyPreset(MetricPresets.money('')),
                        ),
                      ],
                    ),
                    const SizedBox(height: Gaps.m),
                  ],
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          key: const Key('metricName'),
                          controller: _name,
                          decoration: InputDecoration(
                            labelText: l10n.editFieldTitle,
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? l10n.editFieldTitleError
                              : null,
                        ),
                      ),
                      const SizedBox(width: Gaps.s),
                      Expanded(
                        child: TextFormField(
                          key: const Key('metricUnit'),
                          controller: _unit,
                          decoration: InputDecoration(
                            labelText: l10n.metricUnit,
                            hintText: '%, тг, XP',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Gaps.m),
                  Wrap(
                    spacing: Gaps.s,
                    runSpacing: Gaps.s,
                    children: [
                      for (final icon in MetricIcon.values)
                        ChoiceChip(
                          showCheckmark: false,
                          label: Icon(icon.iconData, size: 22),
                          selected: icon == _icon,
                          onSelected: (_) => setState(() => _icon = icon),
                        ),
                    ],
                  ),
                  const SizedBox(height: Gaps.l),
                  Text(l10n.metricMode, style: theme.textTheme.titleSmall),
                  const SizedBox(height: Gaps.s),
                  SegmentedButton<MetricMode>(
                    showSelectedIcon: false,
                    segments: [
                      for (final m in MetricMode.values)
                        ButtonSegment(value: m, label: Text(m.label(l10n))),
                    ],
                    selected: {_mode},
                    onSelectionChanged: (s) => setState(() => _mode = s.first),
                  ),
                  const SizedBox(height: Gaps.s),
                  Text(
                    _mode.hint(l10n),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: Gaps.m),
                  TextFormField(
                    key: const Key('metricStart'),
                    controller: _start,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.metricStartLabel,
                    ),
                    validator: (v) =>
                        _parse(v ?? '') == null ? l10n.editTargetError : null,
                  ),
                  const SizedBox(height: Gaps.m),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          key: const Key('metricGain'),
                          controller: _gain,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: l10n.metricMaxGain,
                            prefixText: '+',
                          ),
                          validator: (v) => _positive(v, l10n),
                        ),
                      ),
                      const SizedBox(width: Gaps.s),
                      Expanded(
                        child: TextFormField(
                          key: const Key('metricLoss'),
                          controller: _loss,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: l10n.metricMaxLoss,
                            prefixText: '−',
                          ),
                          validator: (v) => _positive(v, l10n),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Gaps.s),
                  Text(
                    l10n.metricLossHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: Gaps.l),
                  FilledButton.icon(
                    key: const Key('metricSave'),
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
