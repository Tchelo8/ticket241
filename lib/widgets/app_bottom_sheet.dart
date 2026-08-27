import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';

/// Feuille modale du système : voile flouté, fond bg, rayons hauts 16px,
/// ombre shl, poignée 42×4px, en-tête avec sur-titre/titre/fermeture puis
/// la paire de filets épais/fin.
class AppBottomSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required String kicker,
    required String title,
    required Widget child,
    double maxHeightFraction = 0.88,
  }) {
    final c = context.appColors;
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x70100F0E),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: maxHeightFraction,
          maxChildSize: maxHeightFraction,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: c.bg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.sheetTop)),
                boxShadow: context.tokens.shadows.shl,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(color: c.line2, borderRadius: BorderRadius.circular(99)),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 16, AppSpacing.screen, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                kicker.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.16 * 10,
                                  color: c.acc,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(title, style: Theme.of(context).textTheme.titleLarge),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(color: c.surf, shape: BoxShape.circle),
                            child: Icon(PhosphorIcons.x(), size: 18, color: c.ink),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 14, AppSpacing.screen, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(height: 3, color: c.ink),
                        const SizedBox(height: 1),
                        Container(height: 1, color: c.ink),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 16, AppSpacing.screen, 24),
                      child: child,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
