import 'package:flutter/material.dart';
import '../../core/theme/theme_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

/// "▲ +12% vs last week" — arrow and colour carry the direction, the number
/// carries the size. Within half a percent reads as flat rather than a
/// meaningless "+0%". [labelFor] wraps the signed number in the caller's own
/// localized sentence (e.g. `l10n.adminTrendVsLastWeek`).
class TrendLabel extends StatelessWidget {
  final double percent;
  final String Function(String signedPercent) labelFor;

  const TrendLabel({super.key, required this.percent, required this.labelFor});

  @override
  Widget build(BuildContext context) {
    final flat = percent.abs() < 0.5;
    final up = percent > 0;
    final color = flat
        ? context.textSecondary
        : up
        ? AppColors.success
        : AppColors.error;
    final icon = flat
        ? Icons.trending_flat_rounded
        : up
        ? Icons.trending_up_rounded
        : Icons.trending_down_rounded;
    final sign = flat ? '' : (up ? '+' : '−');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            labelFor('$sign${percent.abs().round()}'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
