import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import 'press_corners_painter.dart';

/// Le gabarit d'état vide unique, réutilisé sur Favoris / Mes billets /
/// Notifications (et sa composition reprise sur le Succès) :
/// cadre à coins de presse -> animation Lottie -> titre en deux temps
/// (2e ligne italique) -> une phrase -> CTA plein -> lien secondaire.
class EmptyStateTemplate extends StatelessWidget {
  final String lottieAsset;
  final String titleLine1;
  final String titleLine2;
  final String body;
  final String primaryLabel;
  final PhosphorIconData primaryIcon;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  const EmptyStateTemplate({
    super.key,
    required this.lottieAsset,
    required this.titleLine1,
    required this.titleLine2,
    required this.body,
    required this.primaryLabel,
    required this.primaryIcon,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenForm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: c.surf,
              borderRadius: BorderRadius.circular(AppRadii.poster),
              border: Border.all(color: c.line2, width: 1),
            ),
            child: CustomPaint(
              painter: PressCornersPainter(color: c.line2),
              child: SizedBox(
                height: 154,
                child: Center(
                  child: SizedBox(
                    width: 154,
                    height: 154,
                    child: Lottie.asset(lottieAsset, fit: BoxFit.contain, repeat: true),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 26),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(children: [
              TextSpan(
                text: '$titleLine1\n',
                style: TextStyle(
                  fontFamily: Theme.of(context).textTheme.headlineSmall?.fontFamily,
                  fontSize: 29,
                  fontWeight: FontWeight.w600,
                  height: 1.15,
                  color: c.ink,
                ),
              ),
              TextSpan(
                text: titleLine2,
                style: TextStyle(
                  fontFamily: Theme.of(context).textTheme.headlineSmall?.fontFamily,
                  fontSize: 29,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.italic,
                  height: 1.15,
                  color: c.ink2,
                ),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          Text(
            body,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15.5, color: c.ink2, height: 1.5),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: onPrimary,
              icon: PhosphorIcon(primaryIcon, size: 19, color: c.onAcc),
              label: Text(primaryLabel),
            ),
          ),
          if (secondaryLabel != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(onPressed: onSecondary, child: Text(secondaryLabel!)),
            ),
          ],
        ],
      ),
    );
  }
}
