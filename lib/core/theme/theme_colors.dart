import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_shadows.dart';

/// Brightness-aware colours, so a widget asks the *context* for "the text
/// colour" instead of hard-coding `AppColors.textSecondaryLight` (which is
/// unreadable on a dark surface). Every token here already exists in
/// [AppColors] — this only picks the right one for the active theme.
extension AppThemeX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get textPrimary =>
      isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

  Color get textSecondary =>
      isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

  /// Card / sheet / input surface.
  Color get surface => isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

  /// Visible hairline for cards, dividers and outlined controls.
  Color get border => isDark ? AppColors.borderDark : AppColors.borderLight;

  /// Fill for controls that sit *on* a [surface] — steppers, chips, tinted
  /// rows. One step away from the surface in either theme.
  Color get inset => isDark ? AppColors.surfaceDark2 : AppColors.cardBorder;

  /// The one card look: surface fill, a border you can actually see, and a
  /// soft shadow in light mode only (shadows vanish on dark surfaces).
  BoxDecoration cardDecoration({double radius = 16, Color? color}) {
    return BoxDecoration(
      color: color ?? surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: border),
      boxShadow: isDark ? null : AppShadows.card,
    );
  }
}
