import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/route_names.dart';
import '../../../core/utils/weight_formatter.dart';
import '../../../domain/entities/cart_item_entity.dart';
import '../../../domain/value_objects/money.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/qty_stepper.dart';
import '../controllers/cart_controller.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartControllerProvider);
    final minimum = Money(AppConstants.kMinOrderAmount);
    final belowMinimum = cart.subtotal < minimum;

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: cart.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.shopping_cart_outlined,
              title: 'Your cart is empty',
              message: 'Browse categories to add wholesale items.',
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _CartItemTile(item: cart.items[index]),
                  ),
                ),
                if (belowMinimum)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Add ${(minimum - cart.subtotal).formatted} more to reach the ${minimum.formatted} minimum order.',
                      style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.warning, fontWeight: FontWeight.w600),
                    ),
                  ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Subtotal', style: GoogleFonts.inter(fontSize: 14)),
                            Text(
                              cart.subtotal.formatted,
                              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        PrimaryButton(
                          label: 'Proceed to Checkout',
                          icon: Icons.arrow_forward_rounded,
                          onPressed: belowMinimum ? null : () => context.push(RouteNames.checkout),
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

class _CartItemTile extends ConsumerWidget {
  final CartItemEntity item;

  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isDark ? Colors.white12 : Colors.black12,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.image_outlined),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 4),
                Text(item.totalPrice.formatted, style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                if (item.isWeighed)
                  Text(
                    '${formatGrams(item.qty)} @ ₹${item.ratePerKg!.toStringAsFixed(0)}/kg',
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondaryLight),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                onPressed: () => ref.read(cartControllerProvider.notifier).removeItem(item.productId),
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
                onChanged: (qty) => ref.read(cartControllerProvider.notifier).updateQty(item.productId, qty),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
