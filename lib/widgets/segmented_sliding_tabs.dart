import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';

/// Sélecteur segmenté (Mes billets : À venir / Passés). Padding 4px sur fond
/// surf, rayon 99px. La pastille active est un bloc `card` qui glisse en
/// 340ms entre les deux moitiés ; le libellé actif passe en cyan.
class SegmentedSlidingTabs extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const SegmentedSlidingTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: c.surf, borderRadius: BorderRadius.circular(99)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth = constraints.maxWidth / labels.length;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 340),
                curve: AppMotion.elastic,
                left: segmentWidth * selectedIndex,
                width: segmentWidth,
                top: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: c.card,
                    borderRadius: BorderRadius.circular(99),
                    boxShadow: context.tokens.shadows.sh,
                  ),
                ),
              ),
              Row(
                children: List.generate(labels.length, (i) {
                  final active = i == selectedIndex;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onChanged(i),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        height: 40,
                        alignment: Alignment.center,
                        child: Text(
                          labels[i],
                          style: TextStyle(
                            fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
                            fontSize: 14.5,
                            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                            color: active ? c.acc : c.ink2,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}
