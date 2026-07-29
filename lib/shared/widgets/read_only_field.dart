import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

/// A locked, non-editable info row — visually distinct from a
/// `TextFormField` (filled muted background, no border, small lock icon) so
/// it reads unambiguously as "not editable here" rather than as a form
/// field the user can tap into.
class ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const ReadOnlyField({
    super.key,
    required this.label,
    required this.value,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.04) : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: AppColors.textSecondaryLight),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondaryLight)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.textSecondaryLight.withOpacity(0.6)),
        ],
      ),
    );
  }
}
