import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'design_tokens.dart';

/// Construit un [ThemeData] complet pour une variante Ticket241 (Papier/Encre/N&B).
/// Les 3 thèmes sont des choix explicites (Profil > Apparence), pas liés au
/// thème système : main.dart choisit `theme:` selon ThemeProvider, jamais
/// `darkTheme`/`themeMode`.
class AppTheme {
  static ThemeData build(AppThemeVariant variant) {
    final t = AppColorTokens.forVariant(variant);
    final base = GoogleFonts.sourceSerif4TextTheme();

    TextStyle serif({
      required double size,
      required FontWeight weight,
      double? height,
      double? letterSpacing,
      bool italic = false,
      Color? color,
    }) {
      return GoogleFonts.sourceSerif4(
        fontSize: size,
        fontWeight: weight,
        height: height,
        letterSpacing: letterSpacing,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        color: color ?? t.ink,
      );
    }

    final textTheme = base.copyWith(
      // Titre d'écran (Accueil, Explorer, Favoris…)
      headlineMedium: serif(size: 30, weight: FontWeight.w600, height: 1.0, letterSpacing: -0.028 * 30),
      // Titre de héros (onboarding, états vides)
      displaySmall: serif(size: 40, weight: FontWeight.w600, height: 1.04, letterSpacing: -0.025 * 40),
      // Titre de détail d'événement
      headlineLarge: serif(size: 34, weight: FontWeight.w600, height: 1.04, letterSpacing: -0.030 * 34),
      // Titre d'affiche (carrousel)
      headlineSmall: serif(size: 27, weight: FontWeight.w600, height: 1.08, letterSpacing: -0.024 * 27),
      // Titre de section
      titleLarge: serif(size: 23, weight: FontWeight.w600, letterSpacing: -0.020 * 23),
      // Titre de carte
      titleMedium: serif(size: 16.5, weight: FontWeight.w600, height: 1.20, letterSpacing: -0.016 * 16.5),
      titleSmall: serif(size: 14.5, weight: FontWeight.w600, height: 1.20, letterSpacing: -0.016 * 14.5),
      // Corps de texte
      bodyLarge: serif(size: 16, weight: FontWeight.w400, height: 1.55, color: t.ink2),
      bodyMedium: serif(size: 15, weight: FontWeight.w400, height: 1.55, color: t.ink2),
      // Libellé de champ
      labelLarge: serif(size: 12.5, weight: FontWeight.w500, color: t.ink2),
      // Sur-titre en capitales
      labelSmall: serif(size: 10, weight: FontWeight.w600, letterSpacing: 0.16 * 10, color: t.acc),
      // Prix, dates, références (tabulaires — appliquer AppText.tabular en plus)
      labelMedium: serif(size: 15, weight: FontWeight.w600, color: t.ink),
    ).apply(bodyColor: t.ink, displayColor: t.ink);

    final colorScheme = variant == AppThemeVariant.ink
        ? ColorScheme.dark(
            surface: t.bg,
            onSurface: t.ink,
            primary: t.acc,
            onPrimary: t.onAcc,
            secondary: t.acc2,
            error: t.acc2,
          )
        : ColorScheme.light(
            surface: t.bg,
            onSurface: t.ink,
            primary: t.acc,
            onPrimary: t.onAcc,
            secondary: t.acc2,
            error: t.acc2,
          );

    return ThemeData(
      useMaterial3: true,
      brightness: variant == AppThemeVariant.ink ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: t.bg,
      colorScheme: colorScheme,
      textTheme: textTheme,
      fontFamily: GoogleFonts.sourceSerif4().fontFamily,
      dividerColor: t.line,
      splashFactory: NoSplash.splashFactory,
      cardTheme: CardThemeData(
        color: t.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
          side: BorderSide(color: t.line, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: t.acc,
          foregroundColor: t.onAcc,
          disabledBackgroundColor: t.surf,
          disabledForegroundColor: t.ink3,
          minimumSize: const Size.fromHeight(AppSizes.buttonMax),
          textStyle: serif(size: 15.5, weight: FontWeight.w600, color: t.onAcc),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.control)),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: t.ink,
          side: BorderSide(color: t.line2, width: 1),
          minimumSize: const Size.fromHeight(AppSizes.buttonMin - 2),
          textStyle: serif(size: 15, weight: FontWeight.w600, color: t.ink),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.control)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: t.acc,
          textStyle: serif(size: 14, weight: FontWeight.w600, color: t.acc),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: t.card,
        hintStyle: serif(size: 15, weight: FontWeight.w400, color: t.ink3),
        labelStyle: serif(size: 12.5, weight: FontWeight.w500, color: t.ink2),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
          borderSide: BorderSide(color: t.line2, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
          borderSide: BorderSide(color: t.line2, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
          borderSide: BorderSide(color: t.acc, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
          borderSide: BorderSide(color: t.acc2, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
          borderSide: BorderSide(color: t.acc2, width: 1.5),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),
      extensions: [AppTokens(colors: t, shadows: AppShadows.forVariant(variant), variant: variant)],
    );
  }
}

/// ThemeExtension pour accéder aux jetons Ticket241 depuis n'importe quel
/// widget via `Theme.of(context).extension<AppTokens>()!`.
class AppTokens extends ThemeExtension<AppTokens> {
  final AppColorTokens colors;
  final AppShadows shadows;
  final AppThemeVariant variant;

  const AppTokens({required this.colors, required this.shadows, required this.variant});

  @override
  AppTokens copyWith({AppColorTokens? colors, AppShadows? shadows, AppThemeVariant? variant}) {
    return AppTokens(
      colors: colors ?? this.colors,
      shadows: shadows ?? this.shadows,
      variant: variant ?? this.variant,
    );
  }

  @override
  ThemeExtension<AppTokens> lerp(covariant ThemeExtension<AppTokens>? other, double t) {
    return other is AppTokens ? other : this;
  }
}

extension AppTokensContext on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;
  AppColorTokens get appColors => tokens.colors;
}

/// Chiffres tabulaires alignés — prix, dates, compteurs, références de billet.
class AppText {
  static TextStyle tabular(TextStyle style) => style.copyWith(
        fontFeatures: const [FontFeature.tabularFigures(), FontFeature.liningFigures()],
      );
}
