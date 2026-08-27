import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/theme/design_tokens.dart';
import 'package:myapp/widgets/empty_state_template.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 8, AppSpacing.screen, 12),
              child: Row(
                children: [
                  GestureDetector(onTap: () => context.go('/app'), child: Icon(PhosphorIconsRegular.arrowLeft, color: c.ink)),
                  const SizedBox(width: 14),
                  Text('Notifications', style: Theme.of(context).textTheme.headlineMedium),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: EmptyStateTemplate(
                  lottieAsset: 'assets/animations/notif.json',
                  titleLine1: 'Tout est calme',
                  titleLine2: 'de ce côté.',
                  body: 'Nous vous préviendrons pour les mises en vente, les rappels d\'événement et vos confirmations de paiement.',
                  primaryLabel: 'Gérer mes alertes',
                  primaryIcon: PhosphorIconsRegular.gear,
                  onPrimary: () => context.push('/profile'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
