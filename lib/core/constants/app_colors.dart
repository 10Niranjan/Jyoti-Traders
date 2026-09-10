import 'package:flutter/material.dart';

/// [AppColors] defines the color system for the application.
/// Following professional design guidelines, we avoid generic/harsh primaries
/// and instead use tailored semantic tokens.
@immutable
class AppColors {
  const AppColors._();

  // Brand Primaries — "Zepto Violet" (chosen from the visual-direction
  // mockup over the original Wholesale Blue).
  static const Color primary = Color(0xFF7C3AED); // Zepto Violet
  static const Color primaryLight = Color(
    0xFFA78BFA,
  ); // used on dark surfaces (e.g. promo gradients)
  static const Color primaryDark = Color(0xFF5B21B6);

  // Secondary / Accents
  static const Color accent = Color(0xFF0D9488); // Teal
  static const Color accentLight = Color(
    0xFF2DD4BF,
  ); // used on dark surfaces (e.g. floating cart bar)

  // Neutral Background & Surfaces
  static const Color backgroundLight = Color(
    0xFFF1F0F5,
  ); // Lavender-tinted off-white
  static const Color surfaceLight = Color(0xFFFFFFFF);

  static const Color backgroundDark = Color(0xFF0F172A); // Deep Slate Blue
  static const Color surfaceDark = Color(0xFF1E293B);

  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF2563EB);

  // Discount & Promotional Badges
  static const Color discountBadge = Color(
    0xFF16A34A,
  ); // Emerald green for discounts

  /// Hairline card border — exact `slate-100` match, used app-wide for
  /// `bg-white rounded-2xl border border-slate-100 shadow-sm` style cards.
  static const Color cardBorder = Color(0xFFF1F5F9);

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
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);

  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
}
