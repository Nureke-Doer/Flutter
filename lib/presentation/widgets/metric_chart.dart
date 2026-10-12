import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Линейный график значения метрики по дням (без сторонних библиотек).
///
/// Рисуется через `CustomPainter` — один холст вместо сотни виджетов.
/// `RepaintBoundary` отделяет график от остального экрана: он
/// перерисовывается только когда меняются сами значения.
class MetricChart extends StatelessWidget {
  const MetricChart({super.key, required this.values, this.height = 160});

  /// Значения по порядку дней (старые → новые).
  final List<double> values;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return RepaintBoundary(
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: _ChartPainter(
            values: values,
            line: scheme.primary,
            zero: scheme.outlineVariant,
            negative: scheme.error,
          ),
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter({
    required this.values,
    required this.line,
    required this.zero,
    required this.negative,
  });

  final List<double> values;
  final Color line;
  final Color zero;
  final Color negative;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final points = values.length == 1 ? [values.first, values.first] : values;
    final minV = math.min(0, points.reduce(math.min)).toDouble();
    final maxV = math.max(0, points.reduce(math.max)).toDouble();
    final range = maxV - minV == 0 ? 1 : maxV - minV;
    double y(double v) => size.height - (v - minV) / range * size.height;
    double x(int i) => i / (points.length - 1) * size.width;

    // Линия нуля.
    canvas.drawLine(
      Offset(0, y(0)),
      Offset(size.width, y(0)),
      Paint()
        ..color = zero
        ..strokeWidth = 1,
    );

    final path = Path()..moveTo(x(0), y(points[0]));
    for (var i = 1; i < points.length; i++) {
      path.lineTo(x(i), y(points[i]));
    }
    final fill = Path.from(path)
      ..lineTo(size.width, y(0))
      ..lineTo(0, y(0))
      ..close();
    canvas.drawPath(fill, Paint()..color = line.withValues(alpha: 0.12));
    canvas.drawPath(
      path,
      Paint()
        ..color = points.last < 0 ? negative : line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_ChartPainter old) =>
      old.values != values || old.line != line;
}
