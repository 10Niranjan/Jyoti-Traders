import 'package:flutter/material.dart';
import '../../../core/theme/theme_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_shadows.dart';

/// One tappable settings row: icon, title, optional current value (or
/// subtitle) and a chevron — the account-page row every grocery app uses.
/// Tapping opens a sheet/dialog, so the page itself stays short.
class SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;

  /// Current value shown on the right (e.g. "Light", "English").
  final String? value;

  /// Longer explanation shown under the title (e.g. the account email).
  final String? subtitle;
  final VoidCallback onTap;

  /// Tints the icon and title — used for destructive rows.
  final Color? color;

  const SettingsRow({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.value,
    this.subtitle,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.primary),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!, style: GoogleFonts.inter(fontSize: 12)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            Text(
              value!,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: context.textSecondary,
              ),
            ),
          Icon(Icons.chevron_right, color: context.textSecondary),
        ],
      ),
      onTap: onTap,
    );
  }
}

/// A card holding several [SettingsRow]s with hairline dividers between them.
/// Same border/shadow chrome as `SectionCard`. The `Material` gives the
/// rows' ink splashes an ancestor to paint on.
class SettingsGroup extends StatelessWidget {
  final List<Widget> children;

  const SettingsGroup({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border),
        boxShadow: isDark ? null : AppShadows.card,
      ),
      child: Material(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const Divider(height: 1, indent: 56),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}
