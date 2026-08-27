import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';

/// Pastille de catégorie / filtre. Deux styles :
/// - [PillChipStyle.category] : active = fond ink/texte bg, inactive = fond card/texte ink2 + filet line2.
/// - [PillChipStyle.activeFilter] : fond accs, filet+texte cyan, croix optionnelle de suppression.
enum PillChipStyle { category, activeFilter }

class PillChip extends StatelessWidget {
  final String label;
  final bool selected;
  final PhosphorIconData? icon;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final PillChipStyle style;

  const PillChip({
    super.key,
    required this.label,
    this.selected = false,
    this.icon,
    this.onTap,
    this.onRemove,
    this.style = PillChipStyle.category,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;

    late final Color bg;
    late final Color fg;
    late final Color? border;

    if (style == PillChipStyle.activeFilter) {
      bg = c.accs;
      fg = c.acc;
      border = c.acc;
    } else if (selected) {
      bg = c.ink;
      fg = c.bg;
      border = null;
    } else {
      bg = c.card;
      fg = c.ink2;
      border = c.line2;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppSizes.filterPill,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: border != null ? Border.all(color: border, width: 1) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              PhosphorIcon(icon!, size: 16, color: fg),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
            if (onRemove != null) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onRemove,
                child: PhosphorIcon(PhosphorIcons.x(), size: 14, color: fg),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
