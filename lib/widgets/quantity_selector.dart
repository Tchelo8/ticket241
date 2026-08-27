import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../theme/app_theme.dart';

/// Sélecteur de quantité : bouton "−" en contour, chiffre tabulaire au centre,
/// bouton "+" en aplat cyan. Taille par défaut 34px (Détail), 30px (Paiement).
class QuantitySelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final double buttonSize;

  const QuantitySelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.buttonSize = 34,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Btn(
          size: buttonSize,
          filled: false,
          borderColor: c.line2,
          iconColor: c.ink,
          icon: PhosphorIcons.minus(),
          onTap: value > min ? () => onChanged(value - 1) : null,
        ),
        SizedBox(
          width: buttonSize * 0.9,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: c.ink,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        _Btn(
          size: buttonSize,
          filled: true,
          fillColor: c.acc,
          iconColor: c.onAcc,
          icon: PhosphorIcons.plus(),
          onTap: () => onChanged(value + 1),
        ),
      ],
    );
  }
}

class _Btn extends StatelessWidget {
  final double size;
  final bool filled;
  final Color? fillColor;
  final Color? borderColor;
  final Color iconColor;
  final PhosphorIconData icon;
  final VoidCallback? onTap;

  const _Btn({
    required this.size,
    required this.filled,
    this.fillColor,
    this.borderColor,
    required this.iconColor,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: filled ? fillColor : Colors.transparent,
          borderRadius: BorderRadius.circular(size / 2),
          border: !filled ? Border.all(color: borderColor!, width: 1) : null,
        ),
        alignment: Alignment.center,
        child: Opacity(
          opacity: disabled ? 0.4 : 1,
          child: PhosphorIcon(icon, size: size * 0.5, color: iconColor),
        ),
      ),
    );
  }
}
