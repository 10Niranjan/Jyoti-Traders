import 'package:flutter/material.dart';

/// [AppColors] defines the color system for the application.
/// Following professional design guidelines, we avoid generic/harsh primaries
/// and instead use tailored semantic tokens.
@immutable
class AppColors {
  const AppColors._();

  // Brand Primaries — "Saffron Dusk" (client-supplied design system,
  // replacing "Zepto Violet"). Flat single values shared by both themes:
  // the source PDFs give slightly different shades per brightness, but
  // this app's ~274 raw call sites of these five tokens were never
  // brightness-split even under the old palette, and splitting them now
  // would mean threading `isDark ? X : Y` through hundreds of sites
  // (many with no `isDark` computed today) for a subtle shade difference.
  // Using the Light-doc values, since Light is this app's default theme.
  static const Color primary = Color(0xFFD9581F); // Saffron 600
  static const Color primaryLight = Color(0xFFF2703C); // Saffron 500
  static const Color primaryDark = Color(0xFFB8461F); // Saffron 700

  // Secondary / Accents
  static const Color accent = Color(0xFFC97D1E); // Gold 600
  static const Color accentLight = Color(0xFFE0A94A); // Gold 400

  // Neutral Background & Surfaces
  static const Color backgroundLight = Color(0xFFFBF1E4); // Warm cream
  static const Color surfaceLight = Color(0xFFFFFFFF);

  static const Color backgroundDark = Color(0xFF14162A);
  static const Color surfaceDark = Color(0xFF1E2136);

  /// Outside the app frame (status bar / hero gradient far edge) —
  /// darker than [backgroundDark], not a general-purpose surface.
  static const Color canvasDark = Color(0xFF08090F);

  /// Elevated bars (app bars) in dark mode — one step lighter than
  /// [surfaceDark], which stays for cards/sheets.
  static const Color surfaceDark2 = Color(0xFF262A45);

  // Semantic Colors
  static const Color success = Color(0xFF1FA971);
  static const Color warning = Color(0xFFE2932F);
  static const Color error = Color(0xFFD9483F);

  /// Hairline card/input border — used app-wide in light mode.
  static const Color cardBorder = Color(0xFFF1F5F9);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF2C3050);

  /// A fixed dark navy, deliberately the same in both themes — for
  /// surfaces meant to always read as "ink dark" regardless of the
  /// active theme (e.g. the floating cart bar's pill).
  static const Color inkNavy = Color(0xFF241F45);

  /// Rotating accent set for category rings — a category's color is
  /// `categoryPalette[index % categoryPalette.length]`. Tint backgrounds are
  /// derived at the call site via `.withOpacity()`, matching how every other
  /// tinted surface in this app already works (see `CategoryCard`).
  ///
  /// Fixed regardless of brand palette (unlike [primary]/[accent]) — these
  /// eight colors exist purely to make an 8+ item category grid scannable at
  /// a glance, matching the Figma reference's own 8-color category set.
  static const List<Color> categoryPalette = [
    Color(0xFFD97706), // Amber
    Color(0xFFEA580C), // Orange
    Color(0xFF0D9488), // Teal
    Color(0xFF7C3AED), // Violet
    Color(0xFFDB2777), // Pink
    Color(0xFF92400E), // Brown
    Color(0xFF2563EB), // Blue
    Color(0xFFDC2626), // Red
  ];

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF241F45); // Dark navy
  static const Color textSecondaryLight = Color(0xFF6B6690);

  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFF9599B0);
}
