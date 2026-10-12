import 'package:flutter/material.dart';

import '../../core/utils/number_utils.dart';
import '../../l10n/generated/app_localizations.dart';

/// Диалог ввода числа. Возвращает число или `null` (отмена).
///
/// Контроллер поля живёт в `State` диалога и освобождается вместе с ним —
/// если освободить его сразу после `showDialog`, анимация закрытия
/// обратится к уже удалённому контроллеру.
Future<double?> showNumberDialog(
  BuildContext context, {
  required String title,
  String? unit,
  bool allowNegative = false,
}) => showDialog<double>(
  context: context,
  builder: (_) =>
      _NumberDialog(title: title, unit: unit, allowNegative: allowNegative),
);

class _NumberDialog extends StatefulWidget {
  const _NumberDialog({
    required this.title,
    this.unit,
    this.allowNegative = false,
  });

  final String title;
  final String? unit;
  final bool allowNegative;

  @override
  State<_NumberDialog> createState() => _NumberDialogState();
}

class _NumberDialogState extends State<_NumberDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = parseNumber(_controller.text);
    if (value == null || (!widget.allowNegative && value < 0)) return;
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        key: const Key('numberField'),
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.numberWithOptions(
          decimal: true,
          signed: widget.allowNegative,
        ),
        decoration: InputDecoration(suffixText: widget.unit),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          key: const Key('numberSave'),
          onPressed: _submit,
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
