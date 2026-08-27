import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'design_tokens.dart';

/// Applique le filtre du thème courant à une image enfant, comme le prototype :
/// - Encre : brightness(0.92) saturate(0.95)
/// - N&B : grayscale(1) contrast(1.12) brightness(1.02)
/// - Papier : aucun filtre
class ThemedImage extends StatelessWidget {
  final Widget child;
  const ThemedImage({super.key, required this.child});

  // Matrices ColorFilter (ordre RGBA, échelle 0-255).
  static const _mono = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 6,
    0.2126, 0.7152, 0.0722, 0, 6,
    0.2126, 0.7152, 0.0722, 0, 6,
    0, 0, 0, 1, 0,
  ]);

  static const _ink = ColorFilter.matrix(<double>[
    0.92, 0, 0, 0, -8,
    0, 0.92, 0, 0, -8,
    0, 0, 0.92, 0, -8,
    0, 0, 0, 1, 0,
  ]);

  @override
  Widget build(BuildContext context) {
    final variant = context.tokens.variant;
    switch (variant) {
      case AppThemeVariant.ink:
        return ColorFiltered(colorFilter: _ink, child: child);
      case AppThemeVariant.mono:
        return ColorFiltered(colorFilter: _mono, child: child);
      case AppThemeVariant.paper:
        return child;
    }
  }
}
