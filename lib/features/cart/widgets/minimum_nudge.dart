import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/route_names.dart';
import '../../../domain/value_objects/money.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/compact_product_tile.dart';
import '../controllers/cart_nudge_controller.dart';

/// Warning shown while the cart is under the minimum order — the "add ₹X
/// more" line plus a progress bar so the distance to the minimum is visible
/// at a glance, not just stated.
class MinimumNudgeBanner extends StatelessWidget {
  final Money subtotal;
  final Money minimum;

  const MinimumNudgeBanner({
    super.key,
    required this.subtotal,
    required this.minimum,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final progress = (subtotal.amount / minimum.amount).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.cartBelowMinimum(
              (minimum - subtotal).formatted,
              minimum.formatted,
            ),
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: AppColors.warning,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween(end: progress),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOut,
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
              color: AppColors.warning,
              backgroundColor: AppColors.warning.withOpacity(0.18),
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal rail of products that would close the gap to the minimum
/// order — shown as the last row of the cart list, so it scrolls with the
/// cart lines instead of squeezing them. Renders nothing when there is
/// nothing sensible to suggest.
class GapSuggestionRail extends ConsumerWidget {
  final Money minimum;

  const GapSuggestionRail({super.key, required this.minimum});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(cartGapSuggestionsProvider);
    if (products.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context)!.cartNudgeRailTitle(minimum.formatted),
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 196,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) => CompactProductTile(
              key: ValueKey(products[index].id),
              product: products[index],
              onTap: () => context.push(
                RouteNames.productDetailPath(products[index].id),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
