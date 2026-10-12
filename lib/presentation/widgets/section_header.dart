import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Заголовок секции списка.
class SectionHeader extends StatelessWidget {
  const SectionHeader(
    this.title, {
    super.key,
    this.icon,
    this.color,
    this.trailing,
  });

  final String title;
  final IconData? icon;

  /// Цвет заголовка (по умолчанию — основной цвет темы).
  final Color? color;

  /// Виджет справа (например, кнопка).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = color ?? theme.colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(Gaps.xs, Gaps.l, Gaps.xs, Gaps.s),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: accent),
            const SizedBox(width: Gaps.s),
          ],
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
