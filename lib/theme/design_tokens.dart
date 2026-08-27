import 'package:flutter/material.dart';

/// Variante de thème sélectionnable par l'utilisateur (Profil > Apparence).
/// Ne dépend pas du thème système — c'est un choix explicite persisté.
enum AppThemeVariant { paper, ink, mono }

/// Un jeu complet de jetons de couleur pour une variante de thème.
/// Valeurs exactes issues de docs/redesign_handoff.md (section "Jetons de design").
class AppColorTokens {
  final Color bg;
  final Color card;
  final Color surf;
  final Color ink;
  final Color ink2;
  final Color ink3;
  final Color line;
  final Color line2;
  final Color acc;
  final Color accd;
  final Color accs;
  final Color acc2;
  final Color acc2s;
  final Color onAcc;
  final Color glass;

  const AppColorTokens({
    required this.bg,
    required this.card,
    required this.surf,
    required this.ink,
    required this.ink2,
    required this.ink3,
    required this.line,
    required this.line2,
    required this.acc,
    required this.accd,
    required this.accs,
    required this.acc2,
    required this.acc2s,
    required this.onAcc,
    required this.glass,
  });

  static const paper = AppColorTokens(
    bg: Color(0xFFF3F2F2),
    card: Color(0xFFFDFDFC),
    surf: Color(0xFFEAE9E9),
    ink: Color(0xFF201E1D),
    ink2: Color(0xFF605D5D),
    ink3: Color(0xFF9B9797),
    line: Color(0x21201E1D), // rgba(32,30,29,0.13)
    line2: Color(0x42201E1D), // rgba(32,30,29,0.26)
    acc: Color(0xFF0088B0),
    accd: Color(0xFF006786),
    accs: Color(0xFFE4F4FB),
    acc2: Color(0xFFD6006C),
    acc2s: Color(0xFFFFEEF4),
    onAcc: Color(0xFFFFFFFF),
    glass: Color(0xD1F3F2F2), // rgba(243,242,242,0.82)
  );

  static const ink_ = AppColorTokens(
    bg: Color(0xFF1B1A19),
    card: Color(0xFF262423),
    surf: Color(0xFF302E2C),
    ink: Color(0xFFF5F3F1),
    ink2: Color(0xFFBAB6B6),
    ink3: Color(0xFF8A8685),
    line: Color(0x24F3F2F2), // rgba(243,242,242,0.14)
    line2: Color(0x47F3F2F2), // rgba(243,242,242,0.28)
    acc: Color(0xFF62C5EE),
    accd: Color(0xFF99E0FF),
    accs: Color(0x2662C5EE), // rgba(98,197,238,0.15)
    acc2: Color(0xFFFF90B1),
    acc2s: Color(0x26FF90B1), // rgba(255,144,177,0.15)
    onAcc: Color(0xFF11201F),
    glass: Color(0xCC1B1A19), // rgba(27,26,25,0.80)
  );

  static const mono = AppColorTokens(
    bg: Color(0xFFF4F3F2),
    card: Color(0xFFFFFFFF),
    surf: Color(0xFFE9E7E5),
    ink: Color(0xFF141312),
    ink2: Color(0xFF5C5957),
    ink3: Color(0xFF96918E),
    line: Color(0x2E141312), // rgba(20,19,18,0.18)
    line2: Color(0x66141312), // rgba(20,19,18,0.40)
    acc: Color(0xFF141312),
    accd: Color(0xFF000000),
    accs: Color(0xFFE6E3E0),
    acc2: Color(0xFF4A4644),
    acc2s: Color(0xFFE6E3E0),
    onAcc: Color(0xFFFFFFFF),
    glass: Color(0xD1F4F3F2),
  );

  static AppColorTokens forVariant(AppThemeVariant v) {
    switch (v) {
      case AppThemeVariant.paper:
        return paper;
      case AppThemeVariant.ink:
        return ink_;
      case AppThemeVariant.mono:
        return mono;
    }
  }
}

/// Ombres — 3 crans seulement, jamais au-delà (README "Ombres").
class AppShadows {
  final List<BoxShadow> sh;
  final List<BoxShadow> shm;
  final List<BoxShadow> shl;
  const AppShadows({required this.sh, required this.shm, required this.shl});

  static const paper = AppShadows(
    sh: [BoxShadow(color: Color(0x1A2D2B2B), offset: Offset(0, 1), blurRadius: 2)],
    shm: [BoxShadow(color: Color(0x1C2D2B2B), offset: Offset(0, 4), blurRadius: 14)],
    shl: [BoxShadow(color: Color(0x292D2B2B), offset: Offset(0, 14), blurRadius: 38)],
  );

  static const ink_ = AppShadows(
    sh: [BoxShadow(color: Color(0x80000000), offset: Offset(0, 1), blurRadius: 2)],
    shm: [BoxShadow(color: Color(0x80000000), offset: Offset(0, 6), blurRadius: 18)],
    shl: [BoxShadow(color: Color(0x99000000), offset: Offset(0, 16), blurRadius: 40)],
  );

  static AppShadows forVariant(AppThemeVariant v) =>
      v == AppThemeVariant.ink ? ink_ : paper;
}

/// Rayons — README "Espacement et rayons".
class AppRadii {
  static const control = 4.0; // boutons, champs
  static const card = 6.0; // cartes
  static const poster = 8.0; // affiches, cadres d'états vides
  static const sheetTop = 16.0; // haut des feuilles modales
  static const pill = 99.0; // pastilles
}

/// Espacements — README "Espacement et rayons".
class AppSpacing {
  static const screen = 22.0;
  static const screenForm = 30.0;
  static const cardGapMin = 14.0;
  static const cardGapMax = 16.0;
}

/// Hauteurs de contrôle — README "Espacement et rayons".
class AppSizes {
  static const buttonMin = 54.0;
  static const buttonMax = 56.0;
  static const fieldMin = 52.0;
  static const fieldMax = 58.0;
  static const filterPill = 38.0;
  static const minTapTarget = 44.0;
}

/// Durées et courbes d'animation — README "Animations et transitions".
class AppMotion {
  static const tIn = Duration(milliseconds: 420);
  static const tFade = Duration(milliseconds: 320);
  static const tRise = Duration(milliseconds: 500);
  static const tSheet = Duration(milliseconds: 400);
  static const tPop = Duration(milliseconds: 500);
  static const tPulse = Duration(milliseconds: 2600);
  static const tSweep = Duration(milliseconds: 1700);
  static const tBar = Duration(milliseconds: 1900);
  static const staggerStep = Duration(milliseconds: 50);
  static const press = Duration(milliseconds: 160);
  static const cardHover = Duration(milliseconds: 220);

  static const Curve standard = Cubic(0.2, 0.8, 0.2, 1);
  static const Curve elastic = Cubic(0.22, 1, 0.28, 1);
  static const Curve sweep = Cubic(0.5, 0, 0.5, 1);
}
