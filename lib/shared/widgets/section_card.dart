import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

/// A titled card wrapping one logical group of settings/content. Relies on
/// the app-wide `CardTheme` (12px radius, elevation 1 — see `app_theme.dart`)
/// so every section on a settings-style screen reads as one visual system
/// instead of a flat, undifferentiated list.
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
    return Card(
      margin: EdgeInsets.zero,
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
                  child: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15)),
                ),
                ?trailing,
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textSecondaryLight),
              ),
            ],
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
