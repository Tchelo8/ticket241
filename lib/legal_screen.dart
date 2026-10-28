import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:myapp/models/legal_content.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/theme/design_tokens.dart';
import 'package:myapp/widgets/press_rule_header.dart';

/// Conditions de vente ou politique de confidentialité : sections numérotées, comme sur le site.
class LegalScreen extends StatelessWidget {
  final LegalDocument doc;
  const LegalScreen({super.key, required this.doc});

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
              child: GestureDetector(
                onTap: () => context.canPop() ? context.pop() : context.go('/'),
                child: Icon(PhosphorIconsRegular.arrowLeft, color: c.ink),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, 32),
                children: [
                  PressRuleHeader(left: 'Document légal', right: doc.updated),
                  const SizedBox(height: 18),
                  Text(doc.title, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 10),
                  Text(doc.lead, style: TextStyle(fontSize: 15.5, height: 1.5, color: c.ink2)),
                  for (var i = 0; i < doc.sections.length; i++) ...[
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text((i + 1).toString().padLeft(2, '0'),
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.acc,
                                fontFeatures: const [FontFeature.tabularFigures()])),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(doc.sections[i].title,
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: c.ink)),
                        ),
                      ],
                    ),
                    for (final p in doc.sections[i].paragraphs) ...[
                      const SizedBox(height: 8),
                      Text(p, style: TextStyle(fontSize: 14.5, height: 1.55, color: c.ink2)),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
