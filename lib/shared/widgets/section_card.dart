import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_shadows.dart';

/// A titled card wrapping one logical group of settings/content. Flat
/// white/surface card with a hairline border and a subtle shadow — the same
/// `cardBorder`/`AppShadows.card` look every other card in the app uses, not
/// the ambient `CardTheme`'s Material elevation, so a settings-style screen
/// reads as one visual system with the rest of the app instead of a
/// differently-shadowed island of its own.
class SectionCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.subtitle,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(16, 14, 16, 16),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: isDark ? null : AppShadows.card,
      ),
      // A plain `Container` background isn't a `Material` ancestor, so any
      // `ListTile`/`SwitchListTile` inside `child` (this card wraps several,
      // e.g. the Business Hours/Notification rows) would lose its ink
      // splashes — `Material` here provides that ancestor while the outer
      // `Container` supplies the border/shadow chrome around it.
      child: Material(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  ?trailing,
                ],
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
