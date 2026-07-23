import 'package:flutter/material.dart';

/// [AppColors] defines the color system for the application.
/// Following professional design guidelines, we avoid generic/harsh primaries
/// and instead use tailored semantic tokens.
@immutable
class AppColors {
  const AppColors._();

  // Brand Primaries
  static const Color primary = Color(0xFF1D4ED8);      // Tailored Royal Blue
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1E3A8A);
  
  // Secondary / Accents
  static const Color accent = Color(0xFFF97316);       // Premium Orange
  static const Color accentLight = Color(0xFFFB923C);
  
  // Neutral Background & Surfaces
  static const Color backgroundLight = Color(0xFFF8FAFC); // Off-White
  static const Color surfaceLight = Color(0xFFFFFFFF);
  
  static const Color backgroundDark = Color(0xFF0F172A);  // Deep Slate Blue
  static const Color surfaceDark = Color(0xFF1E293B);
  
  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF06B6D4);
  
  // Discount & Promotional Badges
  static const Color discountBadge = Color(0xFF16A34A); // Emerald green for discounts

  /// Rotating accent set for category rings — a category's color is
  /// `categoryPalette[index % categoryPalette.length]`. Tint backgrounds are
  /// derived at the call site via `.withOpacity()`, matching how every other
  /// tinted surface in this app already works (see `CategoryCard`).
  static const List<Color> categoryPalette = [
    primary, // Royal Blue
    accent, // Premium Orange
    Color(0xFF0D9488), // Teal
    Color(0xFF7C3AED), // Violet
    Color(0xFFBE185D), // Pink
    Color(0xFF15803D), // Green
  ];
  
  // Text Colors
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
}
