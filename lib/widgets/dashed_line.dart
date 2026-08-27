import 'package:flutter/material.dart';

/// Filet pointillé horizontal — utilisé sur les encoches de billet et les
/// séparateurs de référence.
class DashedLine extends StatelessWidget {
  final Color color;
  final double height;
  final double dashWidth;
  final double gapWidth;

  const DashedLine({
    super.key,
    required this.color,
    this.height = 1,
    this.dashWidth = 5,
    this.gapWidth = 4,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, height),
      painter: _DashedLinePainter(color: color, dashWidth: dashWidth, gapWidth: gapWidth, height: height),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double gapWidth;
  final double height;

  _DashedLinePainter({
    required this.color,
    required this.dashWidth,
    required this.gapWidth,
    required this.height,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = height;
    double x = 0;
    final y = height / 2;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(x + dashWidth, y), paint);
      x += dashWidth + gapWidth;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) => oldDelegate.color != color;
}
