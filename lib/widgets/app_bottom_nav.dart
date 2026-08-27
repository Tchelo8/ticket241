import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../theme/app_theme.dart';

class _NavTab {
  final String label;
  final PhosphorIconData icon;
  final PhosphorIconData iconFilled;
  const _NavTab(this.label, this.icon, this.iconFilled);
}

const _tabs = [
  _NavTab('Accueil', PhosphorIconsRegular.house, PhosphorIconsFill.house),
  _NavTab('Explorer', PhosphorIconsRegular.magnifyingGlass, PhosphorIconsFill.magnifyingGlass),
  _NavTab('Favoris', PhosphorIconsRegular.heart, PhosphorIconsFill.heart),
  _NavTab('Billets', PhosphorIconsRegular.ticket, PhosphorIconsFill.ticket),
  _NavTab('Profil', PhosphorIconsRegular.user, PhosphorIconsFill.user),
];

/// Barre de navigation basse du système : fond `glass` flouté 18px, filet
/// supérieur `line`, icônes 23px (duotone inactif, fill actif), libellé
/// 10.5px, soulignement 14×2px cyan sous l'onglet actif.
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: c.glass,
            border: Border(top: BorderSide(color: c.line, width: 1)),
          ),
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: SafeArea(
            top: false,
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final tab = _tabs[i];
                final active = i == currentIndex;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(i),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PhosphorIcon(active ? tab.iconFilled : tab.icon, size: 23, color: active ? c.acc : c.ink3),
                        const SizedBox(height: 4),
                        Text(
                          tab.label,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                            color: active ? c.acc : c.ink3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 14,
                          height: 2,
                          color: active ? c.acc : Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
