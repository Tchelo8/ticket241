import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';

/// Interrupteur 46×26px, rail cyan quand actif, pastille blanche glissant
/// sur 20px en 250ms.
class ToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const ToggleSwitch({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: AppMotion.standard,
        width: 46,
        height: 26,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? c.acc : c.surf,
          borderRadius: BorderRadius.circular(99),
          border: value ? null : Border.all(color: c.line2, width: 1),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          curve: AppMotion.standard,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}
