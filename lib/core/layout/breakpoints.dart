import 'package:flutter/widgets.dart';

/// Классы ширины окна по Material 3:
/// compact (< 600) — телефон в портрете, medium (600–839) — телефон
/// в альбомной ориентации / маленький планшет, expanded (≥ 840) — планшет.
enum WindowSize { compact, medium, expanded }

abstract final class Breakpoints {
  static const double medium = 600;
  static const double expanded = 840;

  /// Ширина, начиная с которой у NavigationRail видны подписи.
  static const double large = 1200;

  static WindowSize of(double width) => width >= expanded
      ? WindowSize.expanded
      : width >= medium
      ? WindowSize.medium
      : WindowSize.compact;
}

extension WindowSizeContext on BuildContext {
  /// Класс ширины текущего окна. `MediaQuery.sizeOf` подписывает виджет
  /// только на изменение размера (а не на всё MediaQuery) — меньше
  /// лишних перерисовок.
  WindowSize get windowSize => Breakpoints.of(MediaQuery.sizeOf(this).width);
}
