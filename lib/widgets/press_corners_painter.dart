import 'package:flutter/material.dart';

/// Les 4 équerres de 13px (filets 1.5px) placées à 9px des angles — la
/// citation typographique du système (repères de coupe d'une plaque
/// d'impression). Utilisé sur le cadre du gabarit d'état vide.
class PressCornersPainter extends CustomPainter {
  final Color color;
  final double size;
  final double inset;
  final double strokeWidth;

  const PressCornersPainter({
    required this.color,
    this.size = 13,
    this.inset = 9,
    this.strokeWidth = 1.5,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    void corner(Offset origin, bool right, bool bottom) {
      final dx = right ? -size : size;
      final dy = bottom ? -size : size;
      canvas.drawLine(origin, origin.translate(dx, 0), paint);
      canvas.drawLine(origin, origin.translate(0, dy), paint);
    }

    corner(Offset(inset, inset), false, false);
    corner(Offset(canvasSize.width - inset, inset), true, false);
    corner(Offset(inset, canvasSize.height - inset), false, true);
    corner(Offset(canvasSize.width - inset, canvasSize.height - inset), true, true);
  }

  @override
  bool shouldRepaint(covariant PressCornersPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.size != size || oldDelegate.inset != inset;
}
