import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Indicateurs de carrousel dont la largeur et l'opacité s'interpolent en
/// continu selon la position réelle du PageController — pas de saut discret
/// à la fin du geste. largeur = 8 + 18×proximité, proximité = max(0, 1-|i-position|).
/// Utilisé sur le carrousel "À l'affiche" et l'Onboarding.
class InterpolatedPageIndicator extends StatelessWidget {
  final PageController controller;
  final int count;
  final double activeWidth;
  final double inactiveWidth;
  final double height;

  const InterpolatedPageIndicator({
    super.key,
    required this.controller,
    required this.count,
    this.activeWidth = 26,
    this.inactiveWidth = 8,
    this.height = 3,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        double position = 0;
        if (controller.hasClients && controller.position.haveDimensions) {
          position = controller.page ?? controller.initialPage.toDouble();
        } else {
          position = controller.initialPage.toDouble();
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(count, (i) {
            final proximity = (1 - (i - position).abs()).clamp(0.0, 1.0);
            final width = inactiveWidth + (activeWidth - inactiveWidth) * proximity;
            final opacity = 0.28 + (1 - 0.28) * proximity;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: c.acc.withValues(alpha: opacity),
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
