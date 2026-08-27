import 'dart:math';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// La composition d'anneaux de l'attente USSD : 3 anneaux de pulsation
/// décalés, un anneau pointillé tournant lentement, un anneau de progression
/// tournant vite, et au centre le logo du fournisseur sur un disque `card`.
/// Remplace le `CircularProgressIndicator` générique.
class UssdWaitingRings extends StatefulWidget {
  final Color providerColor;
  final Widget logo;
  final double size;

  const UssdWaitingRings({
    super.key,
    required this.providerColor,
    required this.logo,
    this.size = 174,
  });

  @override
  State<UssdWaitingRings> createState() => _UssdWaitingRingsState();
}

class _UssdWaitingRingsState extends State<UssdWaitingRings> with TickerProviderStateMixin {
  late final AnimationController _pulse =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))..repeat();
  late final AnimationController _dotted =
      AnimationController(vsync: this, duration: const Duration(seconds: 9))..repeat();
  late final AnimationController _progress =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat();

  static const _pulseOffsets = [0.0, 0.85 / 2.6, 1.70 / 2.6];

  @override
  void dispose() {
    _pulse.dispose();
    _dotted.dispose();
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (final offset in _pulseOffsets)
            AnimatedBuilder(
              animation: _pulse,
              builder: (context, _) {
                final t = (_pulse.value + offset) % 1.0;
                final scale = 0.72 + (1.9 - 0.72) * t;
                final opacity = (0.55 * (1 - t)).clamp(0.0, 1.0);
                return Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: widget.size * 0.5,
                      height: widget.size * 0.5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: widget.providerColor, width: 2),
                      ),
                    ),
                  ),
                );
              },
            ),
          AnimatedBuilder(
            animation: _dotted,
            builder: (context, _) {
              return Transform.rotate(
                angle: _dotted.value * 2 * pi,
                child: CustomPaint(
                  size: Size.square(widget.size * 0.86),
                  painter: _DottedRingPainter(color: c.ink.withValues(alpha: 0.5)),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _progress,
            builder: (context, _) {
              return Transform.rotate(
                angle: _progress.value * 2 * pi,
                child: CustomPaint(
                  size: Size.square(widget.size * 0.72),
                  painter: _ProgressRingPainter(trackColor: c.line, accentColor: widget.providerColor),
                ),
              );
            },
          ),
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: c.card,
              shape: BoxShape.circle,
              boxShadow: context.tokens.shadows.shm,
            ),
            alignment: Alignment.center,
            child: widget.logo,
          ),
        ],
      ),
    );
  }
}

class _DottedRingPainter extends CustomPainter {
  final Color color;
  const _DottedRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = Offset(radius, radius);
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    const dashCount = 40;
    const dashAngle = (2 * pi) / dashCount;
    for (var i = 0; i < dashCount; i++) {
      if (i.isOdd) continue;
      final start = i * dashAngle;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, dashAngle * 0.6, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DottedRingPainter oldDelegate) => oldDelegate.color != color;
}

class _ProgressRingPainter extends CustomPainter {
  final Color trackColor;
  final Color accentColor;
  const _ProgressRingPainter({required this.trackColor, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = Offset(radius, radius);
    final rect = Rect.fromCircle(center: center, radius: radius - 1.5);
    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawArc(rect, 0, 2 * pi, false, trackPaint);

    final accentPaint = Paint()
      ..color = accentColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawArc(rect, -pi / 2, pi / 3, false, accentPaint);
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) =>
      oldDelegate.trackColor != trackColor || oldDelegate.accentColor != accentColor;
}
