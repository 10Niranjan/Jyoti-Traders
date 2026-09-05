import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/value_objects/weight_rate_slabs.dart';
import '../../l10n/app_localizations.dart';

/// The full rate card, so a retailer can see what buying more would save.
class RateSlabTable extends StatelessWidget {
  final WeightRateSlabs slabs;

  /// Highlights the band this weight currently falls in.
  final int? activeGrams;

  const RateSlabTable({super.key, required this.slabs, this.activeGrams});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeLabel =
        activeGrams == null ? null : slabs.bandLabelFor(activeGrams!);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.rateSlabTitle, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(
          l10n.rateSlabSubtitle,
          style: GoogleFonts.inter(
            fontSize: 11.5,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.15)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (final band in slabs.bands)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  color: band.label == activeLabel
                      ? AppColors.primary.withOpacity(0.10)
                      : null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        band.label,
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: band.label == activeLabel
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      Text(
                        l10n.ratePerKg(band.ratePerKg.toStringAsFixed(0)),
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: band.label == activeLabel
                              ? AppColors.primary
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
