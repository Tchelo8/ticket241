import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// La "furniture" de presse du système : un filet épais (3px) puis un filet
/// fin (1px), encadrant une ligne de texte gauche/droite. Réutilisée sur la
/// ligne de date de l'Accueil et les en-têtes de feuilles modales.
/// README : "C'est la « furniture » de presse du système : à conserver telle quelle."
class PressRuleHeader extends StatelessWidget {
  final String left;
  final String? right;

  const PressRuleHeader({super.key, required this.left, this.right});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final labelStyle = TextStyle(
      fontFamily: Theme.of(context).textTheme.labelSmall?.fontFamily,
      fontSize: 10,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.20 * 10,
      color: c.ink,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(height: 3, color: c.ink),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(left.toUpperCase(), style: labelStyle)),
              if (right != null)
                Text(right!.toUpperCase(), style: labelStyle, textAlign: TextAlign.right),
            ],
          ),
        ),
        Container(height: 1, color: c.ink),
      ],
    );
  }
}
