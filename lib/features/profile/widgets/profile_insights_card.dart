import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/trend_label.dart';
import '../controllers/profile_insights_controller.dart';

/// "Your business": spend this month against the same days last month, order
/// count, most-bought products and favourite category — all from the order
/// history the app already loads. Renders nothing for a shop with no orders.
class ProfileInsightsCard extends ConsumerWidget {
  const ProfileInsightsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insights = ref.watch(retailerInsightsProvider);
    if (insights == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return SectionCard(
      title: l10n.profileInsightsTitle,
      icon: Icons.insights_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.profileInsightsThisMonth,
            style: GoogleFonts.inter(fontSize: 12, color: muted),
          ),
          const SizedBox(height: 2),
          Text(
            formatRupees(insights.monthSpend),
            style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          if (insights.spendTrend != null) ...[
            const SizedBox(height: 4),
            TrendLabel(
              percent: insights.spendTrend!,
              labelFor: l10n.profileInsightsVsLastMonth,
            ),
          ],
          const SizedBox(height: 10),
          Text(
            l10n.profileInsightsOrdersThisMonth(insights.monthOrders),
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          if (insights.topProducts.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              l10n.profileInsightsMostBought,
              style: GoogleFonts.inter(fontSize: 12, color: muted),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                for (final p in insights.topProducts)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${p.name} · ${p.orders}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ],
          if (insights.topCategory != null) ...[
            const SizedBox(height: 12),
            Text(
              '${l10n.profileInsightsFavCategory}: ${insights.topCategory}',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
