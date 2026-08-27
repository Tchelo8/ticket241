import 'dart:math';
import 'package:flutter/material.dart';

import 'dashed_line.dart';

/// Carte billet avec deux demi-cercles découpés dans les bords gauche et
/// droit à la hauteur [notchY], remplis de [backgroundColor] avec un filet
/// sur leur face interne, et un filet pointillé horizontal à la même
/// hauteur. C'est la silhouette de ticket (Mes billets, Billet en détail).
class TicketNotchCard extends StatelessWidget {
  final Widget top;
  final Widget bottom;
  final Color backgroundColor;
  final Color notchColor;
  final Color lineColor;
  final double notchRadius;
  final double cornerRadius;

  const TicketNotchCard({
    super.key,
    required this.top,
    required this.bottom,
    required this.backgroundColor,
    required this.notchColor,
    required this.lineColor,
    this.notchRadius = 8,
    this.cornerRadius = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        top,
        _NotchDivider(radius: notchRadius, notchColor: notchColor, lineColor: lineColor),
        bottom,
      ],
    );
  }
}

/// La bande d'encoches : filet pointillé + deux demi-cercles peints dans le
/// vide, simulant l'échancrure sur les bords gauche/droit de la carte
/// parente (la carte parente elle-même n'est pas re-découpée : la bande
/// occupe toute la largeur et porte les demi-cercles à ses extrémités).
class _NotchDivider extends StatelessWidget {
  final double radius;
  final Color notchColor;
  final Color lineColor;

  const _NotchDivider({required this.radius, required this.notchColor, required this.lineColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: radius * 2,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 16,
            right: 16,
            child: DashedLine(color: lineColor),
          ),
          Positioned(
            left: -radius,
            child: _Notch(radius: radius, color: notchColor, lineColor: lineColor),
          ),
          Positioned(
            right: -radius,
            child: _Notch(radius: radius, color: notchColor, lineColor: lineColor),
          ),
        ],
      ),
    );
  }
}

class _Notch extends StatelessWidget {
  final double radius;
  final Color color;
  final Color lineColor;

  const _Notch({required this.radius, required this.color, required this.lineColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: lineColor, width: 1),
      ),
    );
  }
}

/// Clipper pour une carte entière découpée avec deux demi-cercles sur ses
/// bords, utilisable directement sur le [Container] de la carte si on
/// préfère la vraie découpe plutôt que la bande simulée ci-dessus.
class TicketEdgeNotchClipper extends CustomClipper<Path> {
  final double notchY;
  final double notchRadius;
  final double cornerRadius;

  const TicketEdgeNotchClipper({
    required this.notchY,
    this.notchRadius = 8,
    this.cornerRadius = 6,
  });

  @override
  Path getClip(Size size) {
    final r = cornerRadius;
    final path = Path()
      ..moveTo(0, r)
      ..quadraticBezierTo(0, 0, r, 0)
      ..lineTo(size.width - r, 0)
      ..quadraticBezierTo(size.width, 0, size.width, r)
      ..lineTo(size.width, notchY - notchRadius)
      ..arcTo(
        Rect.fromCircle(center: Offset(size.width, notchY), radius: notchRadius),
        -pi / 2,
        -pi,
        false,
      )
      ..lineTo(size.width, size.height - r)
      ..quadraticBezierTo(size.width, size.height, size.width - r, size.height)
      ..lineTo(r, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - r)
      ..lineTo(0, notchY + notchRadius)
      ..arcTo(
        Rect.fromCircle(center: Offset(0, notchY), radius: notchRadius),
        pi / 2,
        -pi,
        false,
      )
      ..lineTo(0, r)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant TicketEdgeNotchClipper oldDelegate) =>
      oldDelegate.notchY != notchY || oldDelegate.notchRadius != notchRadius;
}
