import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/theme/theme_colors.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_shadows.dart';
import '../../core/utils/weight_formatter.dart';
import '../../domain/entities/product_entity.dart';
import '../../features/cart/controllers/cart_controller.dart';
import '../../l10n/app_localizations.dart';
import 'add_to_cart_pill.dart';
import 'quantity_sheet.dart';

/// Content width below which [ProductCard] stacks price above its control.
/// A regular 2-column grid card has ~138 dp of content width; the category
/// page's rail layout leaves ~110 dp.
const double _kStackControlBelowWidth = 120;

/// Horizontal padding inside the card's text block (10 + 10).
const double _kCardTextPadding = 20;

/// Height a [ProductCard] of [cardWidth] needs: the square-ish image
/// (`AspectRatio` 1.1) plus the text block, which alone grows with the text
/// size. Every grid/rail that fixes a card's height should use this instead of
/// a hard-coded ratio — a ratio tuned at 1.0x text clips the card's bottom
/// (price/ADD row) once the retailer picks a larger Text size in Settings.
///
/// The constants are measured for a 2-line name with the ADD pill or stepper
/// (the tallest states): 110 dp of text at 158 dp wide, 134 dp when stacked at
/// ~132 dp wide, each with a few dp spare, and how much each gains per +1.0
/// of text scale.
double productCardHeight(BuildContext context, double cardWidth) {
  final scale = MediaQuery.textScalerOf(context).scale(1);
  final stacked = cardWidth - _kCardTextPadding < _kStackControlBelowWidth;
  final text = stacked ? 137 + 87 * (scale - 1) : 113 + 67 * (scale - 1);
  return cardWidth / 1.1 + text;
}

/// Two-column grid delegate for [ProductCard]s — fixed card height from
/// [productCardHeight] for the width the grid is actually given.
SliverGridDelegate productGridDelegate(
  BuildContext context, {
  required double availableWidth,
  double spacing = 12,
}) {
  final cardWidth = (availableWidth - spacing) / 2;
  return SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    mainAxisExtent: productCardHeight(context, cardWidth),
    crossAxisSpacing: spacing,
    mainAxisSpacing: spacing,
  );
}

/// Cart-aware on its own — reads/writes `cartControllerProvider` directly
/// rather than taking an `onAddToCart` callback, so every grid using this
/// card gets the same "+" → quantity sheet → inline stepper behavior for free.
class ProductCard extends ConsumerWidget {
  final ProductEntity product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  void _updateQty(WidgetRef ref, int qty) {
    ref.read(cartControllerProvider.notifier).updateQty(product.id, qty);
  }

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
            Hero(
              tag: 'product-image-${product.id}',
              child: AspectRatio(
                aspectRatio: 1.1,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _ProductImage(imageUrl: product.imageUrl, isDark: isDark),
                    if (!product.isInStock)
                      _OutOfStockOverlay(
                        label: l10n.homeOutOfStock,
                        isDark: isDark,
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.productPerUnit(product.unit.value),
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final price = Text(
                        product.isWeighed
                            ? l10n.homeFromRatePerKg(
                                product.rateSlabs!.bestRatePerKg
                                    .toStringAsFixed(0),
                              )
                            : product.price.formatted,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      );
                      // Nothing to add when out of stock — the photo carries an
                      // "Out of stock" badge instead (see the overlay above).
                      // The old muted pill *plus* a separate note made these
                      // cards ~18 dp taller than in-stock ones and overflowed
                      // the fixed grid cell; this keeps every state within the
                      // ADD/stepper row's height.
                      final Widget control = !product.isInStock
                          ? const SizedBox.shrink()
                          : qtyInCart == 0
                          ? AddToCartPill(
                              onTap: () => showQuantitySheet(context, product),
                            )
                          : _CompactQtyStepper(
                              key: ValueKey(qtyInCart),
                              qty: qtyInCart,
                              max: product.maxQty,
                              step: product.isWeighed
                                  ? weightStepFor(qtyInCart)
                                  : 1,
                              label: product.isWeighed
                                  ? formatGrams(qtyInCart)
                                  : '$qtyInCart',
                              onChanged: (qty) => _updateQty(ref, qty),
                            );
                      // The category page's slim-rail layout makes cards this
                      // narrow; price and control no longer fit side by side
                      // (the price would truncate to "₹1,5…"), so stack them.
                      if (constraints.maxWidth < _kStackControlBelowWidth) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [price, const SizedBox(height: 4), control],
                        );
                      }
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Expanded(child: price), control],
                      );
                    },
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

/// A dense "− qty +" control sized for a 2-column card row, sitting
/// alongside price text. `QtyStepper` (shared/widgets/qty_stepper.dart) is
/// too wide for this — it's built for the full-width row on Product Detail
/// / Cart, a genuinely different size tier, not a duplicate of this one.
///
/// `key: ValueKey(qty)` at the call site replays the entrance scale-bounce
/// on every quantity change (add/±), the same "restart via changing key"
/// pattern `BottomNavBar`'s cart badge already uses — a tap should feel like
/// it landed, not just silently update a number.
class _CompactQtyStepper extends StatelessWidget {
  final int qty;
  final int max;

  /// How much one tap moves [qty] — 1 unit, or a weight step in grams.
  final int step;

  /// Pre-formatted, because grams read as `250 g` / `1 kg`, not a bare count.
  final String label;
  final ValueChanged<int> onChanged;

  const _CompactQtyStepper({
    super.key,
    required this.qty,
    required this.max,
    required this.step,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StepperButton(
                icon: Icons.remove_rounded,
                onTap: () => onChanged(qty - step),
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 18),
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              _StepperButton(
                icon: Icons.add_rounded,
                onTap: qty < max
                    ? () => onChanged((qty + step).clamp(0, max))
                    : null,
              ),
            ],
          ),
        )
        .animate()
        .scale(
          begin: const Offset(0.85, 0.85),
          end: const Offset(1, 1),
          duration: 160.ms,
          curve: Curves.easeOutBack,
        )
        .fadeIn(duration: 120.ms);
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap == null
          ? null
          : () {
              HapticFeedback.selectionClick();
              onTap!();
            },
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Icon(
          icon,
          size: 13,
          color: onTap == null ? Colors.white38 : Colors.white,
        ),
      ),
    );
  }
}

/// Dims the photo and pins an "Out of stock" badge on it — the convention
/// quick-commerce apps use, and height-neutral (it sits on the image).
class _OutOfStockOverlay extends StatelessWidget {
  final String label;
  final bool isDark;

  const _OutOfStockOverlay({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: (isDark ? Colors.black : Colors.white).withOpacity(0.6),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String imageUrl;
  final bool isDark;

  const _ProductImage({required this.imageUrl, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final placeholderColor = isDark ? Colors.white12 : Colors.black12;
    if (imageUrl.isEmpty) {
      return Container(
        color: placeholderColor,
        child: const Icon(Icons.image_outlined, size: 32),
      );
    }
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(color: placeholderColor),
      errorWidget: (context, url, error) => Container(
        color: placeholderColor,
        child: const Icon(Icons.image_outlined, size: 32),
      ),
    );
  }
}
