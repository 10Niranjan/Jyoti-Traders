import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../l10n/app_localizations.dart';
import 'delivery_form_parts.dart';

/// "What retailers will pay": the charge for a few typical distances at the
/// rate being typed, with a bar per row that grows and shrinks with it — so
/// the admin sees what a number means before saving it.
class DeliverySampleCharges extends StatelessWidget {
  static const distancesKm = [2, 5, 10, 25];

  /// The bars are scaled against a fixed ₹500 ceiling. Purely visual: it makes
  /// a higher rate look longer without the bars ever needing to be re-scaled.
  static const _barCeiling = 500.0;

  /// `null` while the rate field doesn't hold a number yet.
  final double? rate;

  const DeliverySampleCharges({super.key, required this.rate});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: context.cardDecoration(radius: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DeliveryCardHeader(
            icon: Icons.route_rounded,
            title: l10n.adminDeliverySamplesTitle,
          ),
          const SizedBox(height: 18),
          for (final km in distancesKm)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _SampleRow(km: km, rate: rate),
            ),
        ],
      ),
    );
  }
}

class _SampleRow extends StatelessWidget {
  final int km;
  final double? rate;

  const _SampleRow({required this.km, required this.rate});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final charge = rate == null ? null : km * rate!;
    final fraction = charge == null
        ? 0.0
        : (charge / DeliverySampleCharges._barCeiling).clamp(0.03, 1.0);

    return Row(
      children: [
        SizedBox(
          width: 62,
          child: Text(
            l10n.adminDeliverySampleKm(km),
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: context.inset,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  height: 12,
                  width: constraints.maxWidth * fraction,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryLight, AppColors.primary],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 14),
        SizedBox(
          width: 84,
          child: Text(
            charge == null ? '—' : formatRupees(charge),
            textAlign: TextAlign.right,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: context.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
