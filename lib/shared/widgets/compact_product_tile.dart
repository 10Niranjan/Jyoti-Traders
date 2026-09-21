import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/theme/theme_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_shadows.dart';
import '../../core/utils/weight_formatter.dart';
import '../../domain/entities/product_entity.dart';
import '../../features/cart/controllers/cart_controller.dart';
import '../../l10n/app_localizations.dart';
import 'add_to_cart_pill.dart';
import 'qty_stepper.dart';
import 'quantity_sheet.dart';

/// Compact horizontal-rail tile — a smaller image and a single-line
/// add/stepper row rather than the full grid `ProductCard`, matching the
/// Figma reference's slimmer rail treatment. Used by Home's "Buy Again" rail
/// and the cart's "reach the minimum" suggestions.
class CompactProductTile extends ConsumerWidget {
  final ProductEntity product;
  final VoidCallback onTap;

  const CompactProductTile({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final qtyInCart = ref.watch(
      cartControllerProvider.select((cart) => cart.qtyFor(product.id)),
    );
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.border),
          boxShadow: isDark ? null : AppShadows.card,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 96,
              width: double.infinity,
              child: product.imageUrl.isEmpty
                  ? Container(
                      color: isDark ? Colors.white12 : Colors.black12,
                      child: const Icon(Icons.image_outlined, size: 28),
                    )
                  : CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      fit: BoxFit.cover,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.isWeighed
                        ? l10n.homeFromRatePerKg(
                            product.rateSlabs!.bestRatePerKg.toStringAsFixed(0),
                          )
                        : product.price.formatted,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (!product.isInStock)
                    OutOfStockPill(isDark: isDark)
                  else if (qtyInCart == 0)
                    AddToCartPill(
                      filled: true,
                      onTap: () => showQuantitySheet(context, product),
                    )
                  else
                    QtyStepper(
                      filled: true,
                      qty: qtyInCart,
                      max: product.maxQty,
                      // A weighed line's qty is grams — step and label it as
                      // weight, not as a count of single grams.
                      step: product.isWeighed ? weightStepFor(qtyInCart) : 1,
                      label: product.isWeighed ? formatGrams(qtyInCart) : null,
                      onChanged: (qty) => ref
                          .read(cartControllerProvider.notifier)
                          .updateQty(product.id, qty),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
