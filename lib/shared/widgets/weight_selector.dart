import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/weight_formatter.dart';
import '../../domain/value_objects/weight_rate_slabs.dart';

/// Weight picker for slab-priced products: quick-pick chips plus a ± stepper,
/// with the rate the current weight earns shown live underneath — so the
/// retailer sees the price drop the moment they cross a band.
class WeightSelector extends StatelessWidget {
  /// Currently selected weight, in grams.
  final int grams;
  final ValueChanged<int> onChanged;
  final WeightRateSlabs slabs;

  /// Stock ceiling in grams.
  final int maxGrams;

  const WeightSelector({
    super.key,
    required this.grams,
    required this.onChanged,
    required this.slabs,
    required this.maxGrams,
  });

  /// Presets deliberately straddle every band boundary (240 g / 999 g /
  /// 2.4 kg), so each rate on the card is reachable in one tap.
  static const _presets = [100, 250, 500, 1000, 2500, 5000];

  void _nudge(int delta) {
    final next = (grams + delta).clamp(100, maxGrams < 100 ? 100 : maxGrams);
    if (next != grams) onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rate = slabs.ratePerKgFor(grams);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select quantity',
          style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final preset in _presets)
              if (preset <= maxGrams)
                ChoiceChip(
                  label: Text(formatGrams(preset)),
                  labelStyle: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: preset == grams ? Colors.white : null,
                  ),
                  selected: preset == grams,
                  selectedColor: AppColors.primary,
                  showCheckmark: false,
                  onSelected: (_) => onChanged(preset),
                ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _StepButton(
                    icon: Icons.remove_rounded,
                    onTap:
                        grams > 100 ? () => _nudge(-weightStepFor(grams - 1)) : null,
                  ),
                  SizedBox(
                    width: 72,
                    child: Text(
                      formatGrams(grams),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  _StepButton(
                    icon: Icons.add_rounded,
                    onTap:
                        grams < maxGrams ? () => _nudge(weightStepFor(grams)) : null,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    slabs.priceFor(grams).formatted,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    '₹${rate.toStringAsFixed(0)}/kg · ${slabs.bandLabelFor(grams)}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Rate by quantity', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
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
                        '₹${band.ratePerKg.toStringAsFixed(0)}/kg',
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

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 18,
          color: onTap == null
              ? AppColors.textSecondaryLight.withOpacity(0.4)
              : AppColors.primary,
        ),
      ),
    );
  }
}
