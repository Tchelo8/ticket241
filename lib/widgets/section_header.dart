import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Titre de section (23px 600) avec un lien traînant optionnel ("Tout voir",
/// "↗ 24 h"...). Utilisé pour Tendances actuelles, Cette semaine, Concerts,
/// Sport, Le calendrier.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? trailingLabel;
  final Color? trailingColor;
  final VoidCallback? onTrailingTap;

  const SectionHeader({
    super.key,
    required this.title,
    this.trailingLabel,
    this.trailingColor,
    this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          if (trailingLabel != null)
            GestureDetector(
              onTap: onTrailingTap,
              child: Text(
                trailingLabel!,
                style: TextStyle(
                  fontFamily: Theme.of(context).textTheme.labelLarge?.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: trailingColor ?? c.acc,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
