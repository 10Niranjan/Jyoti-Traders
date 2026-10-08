import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/route_names.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/weight_formatter.dart';
import '../../../domain/entities/cart_item_entity.dart';
import '../../../domain/usecases/delivery/calculate_delivery_charge_usecase.dart';
import '../../../domain/value_objects/money.dart';
import '../../../shared/widgets/animated_money_row.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/qty_stepper.dart';
import '../../../shared/widgets/summary_row.dart';
import '../../../l10n/app_localizations.dart';
import '../../admin/controllers/admin_delivery_config_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/controllers/auth_state.dart';
import '../controllers/cart_controller.dart';
import '../controllers/coupon_controller.dart';
import '../widgets/minimum_nudge.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final _couponController = TextEditingController();

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartControllerProvider);
    final minimum = Money(AppConstants.kMinOrderAmount);
    final belowMinimum = cart.subtotal < minimum;
    // Same resolver Checkout uses, so this screen's total can never disagree
    // with the one the retailer sees a step later.
    final authState = ref.watch(authControllerProvider);
    final address = authState is AuthenticatedCustomer
        ? authState.user.address
        : null;
    final config = ref.watch(deliveryConfigProvider).valueOrNull;
    final deliveryCharge = resolveDeliveryCharge(
      address: address,
      config: config,
    );
    final couponState = ref.watch(couponControllerProvider);
    // Recomputed off the live subtotal, not frozen at apply time — a cart
    // edit that drops below the coupon's minimum silently zeroes this
    // instead of needing its own invalidation path.
    final discount =
        couponState.coupon?.discountFor(cart.subtotal) ?? Money.zero;
    final total = cart.subtotal - discount + deliveryCharge;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.cartTitle),
        actions: [
          if (!cart.isEmpty)
            TextButton(
              onPressed: () {
                ref.read(cartControllerProvider.notifier).clearCart();
                ref.read(couponControllerProvider.notifier).remove();
              },
              child: Text(l10n.cartClearAll),
            ),
        ],
      ),
      body: cart.isEmpty
          ? EmptyStateWidget(
              icon: Icons.shopping_cart_outlined,
              title: l10n.cartEmptyTitle,
              message: l10n.cartEmptyMessage,
              action: OutlinedButton(
                onPressed: () => context.go(RouteNames.home),
                child: Text(l10n.cartBrowseProducts),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    // One extra trailing row for the suggestion rail while
                    // the cart is under the minimum.
                    itemCount: cart.items.length + (belowMinimum ? 1 : 0),
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        index == cart.items.length
                        ? GapSuggestionRail(minimum: minimum)
                        : _CartItemTile(
                            key: ValueKey(cart.items[index].productId),
                            item: cart.items[index],
                          ),
                  ),
                ),
                if (belowMinimum)
                  MinimumNudgeBanner(subtotal: cart.subtotal, minimum: minimum),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: couponState.coupon == null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _couponController,
                                    textCapitalization:
                                        TextCapitalization.characters,
                                    decoration: InputDecoration(
                                      hintText: l10n.cartCouponHint,
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  onPressed: () {
                                    final applied = ref
                                        .read(couponControllerProvider.notifier)
                                        .apply(
                                          _couponController.text,
                                          cart.subtotal,
                                        );
                                    if (applied) _couponController.clear();
                                  },
                                  child: Text(l10n.cartCouponApply),
                                ),
                              ],
                            ),
                            if (couponState.error != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                couponState.error!,
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ],
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.success.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.local_offer_outlined,
                                size: 16,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  l10n.cartCouponApplied(
                                    couponState.coupon!.code,
                                  ),
                                  style: GoogleFonts.inter(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.success,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => ref
                                    .read(couponControllerProvider.notifier)
                                    .remove(),
                                child: Text(l10n.cartCouponRemove),
                              ),
                            ],
                          ),
                        ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        SummaryRow(
                          label: l10n.cartSubtotal,
                          value: cart.subtotal.formatted,
                        ),
                        if (discount.amount > 0)
                          SummaryRow(
                            label: l10n.cartDiscount,
                            value: '-${discount.formatted}',
                            valueColor: AppColors.success,
                          ),
                        SummaryRow(
                          label: l10n.cartDeliveryCharge,
                          value: deliveryCharge.formatted,
                        ),
                        const Divider(),
                        AnimatedMoneyRow(
                          label: l10n.cartTotal,
                          amount: total.amount,
                          bold: true,
                        ),
                        const SizedBox(height: 12),
                        PrimaryButton(
                          label: l10n.cartProceedToCheckout,
                          icon: Icons.arrow_forward_rounded,
                          onPressed: belowMinimum
                              ? null
                              : () => context.push(RouteNames.checkout),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

/// 500 kg — a sanity ceiling for one cart line. The cart line doesn't carry
/// the product's live stock, so real stock is enforced on the product page.
const int _kMaxLineGrams = 500000;

class _CartItemTile extends ConsumerStatefulWidget {
  final CartItemEntity item;

  const _CartItemTile({super.key, required this.item});

  @override
  ConsumerState<_CartItemTile> createState() => _CartItemTileState();
}

class _CartItemTileState extends ConsumerState<_CartItemTile> {
  // One-way: plays the shrink-out, then the actual removal happens after
  // the tile has visually collapsed instead of just vanishing mid-list.
  bool _removing = false;

  /// Removes the line and offers Undo. Everything the snackbar needs is
  /// captured *before* the await — this tile is disposed the moment the cart
  /// stream drops its line, so touching `context`/`ref` afterwards would fail.
  Future<void> _removeWithUndo() async {
    final item = widget.item;
    final notifier = ref.read(cartControllerProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
    HapticFeedback.mediumImpact();
    await notifier.removeItem(item.productId);
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.cartItemRemoved(item.name)),
          action: SnackBarAction(
            label: l10n.cartUndo,
            onPressed: () => notifier.addItem(item),
          ),
        ),
      );
  }

  /// The delete button: plays the shrink-out first, then removes.
  Future<void> _removeByButton() async {
    setState(() => _removing = true);
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    await _removeWithUndo();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: _removing ? 0 : 1,
        child: _removing ? const SizedBox(width: double.infinity) : _buildTile(context, isDark, item),
      ),
    ).animate().fadeIn(duration: 240.ms, curve: Curves.easeOut).slideX(begin: 0.08, end: 0, duration: 220.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildTile(BuildContext context, bool isDark, CartItemEntity item) {
    return Dismissible(
      key: ValueKey('dismiss-${item.productId}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      // A dismissed Dismissible must leave the tree in the same frame or
      // Flutter asserts, but the cart only drops the line a moment later
      // (Hive stream). Flipping `_removing` swaps this whole widget out now.
      onDismissed: (_) {
        setState(() => _removing = true);
        _removeWithUndo();
      },
      child: _buildTileContent(context, isDark, item),
    );
  }

  Widget _buildTileContent(
    BuildContext context,
    bool isDark,
    CartItemEntity item,
  ) {
    return InkWell(
      // The delete button and QtyStepper below are their own InkWells
      // nested inside this one — Flutter routes a tap to the innermost
      // hit-testable widget first, so they still work independently and
      // never also trigger this row's navigation.
      onTap: () => context.push(RouteNames.productDetailPath(item.productId)),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: context.cardDecoration(radius: 12),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isDark ? Colors.white12 : Colors.black12,
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: item.imageUrl.isEmpty
                  ? const Icon(Icons.image_outlined)
                  : CachedNetworkImage(
                      imageUrl: item.imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.image_outlined),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.totalPrice.formatted,
                    style: GoogleFonts.inter(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (item.isWeighed)
                    Text(
                      AppLocalizations.of(context)!.cartWeightAtRate(
                        formatGrams(item.qty),
                        item.ratePerKg!.toStringAsFixed(0),
                      ),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: context.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                    size: 20,
                  ),
                  tooltip: AppLocalizations.of(context)!.cartRemoveItemTooltip,
                  onPressed: _removeByButton,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(height: 8),
                QtyStepper(
                  qty: item.qty,
                  // The default 999 ceiling counts units; in grams it would cap
                  // a line at under a kilo. Weighed lines get a weight ceiling.
                  max: item.isWeighed ? _kMaxLineGrams : 999,
                  step: item.isWeighed ? weightStepFor(item.qty) : 1,
                  label: item.isWeighed ? formatGrams(item.qty) : '${item.qty}',
                  onChanged: (qty) => ref
                      .read(cartControllerProvider.notifier)
                      .updateQty(item.productId, qty),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
