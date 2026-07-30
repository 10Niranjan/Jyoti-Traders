import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/weight_formatter.dart';
import '../../../domain/entities/cart_item_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/qty_stepper.dart';
import '../../../shared/widgets/weight_selector.dart';
import '../../cart/controllers/cart_controller.dart';
import '../controllers/product_controller.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  /// Grams for a weighed product, whole units otherwise. Seeded from the
  /// product itself the first time it loads, since 1 is a sane starting
  /// count but a nonsense starting weight.
  int? _qty;

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productByIdProvider(widget.productId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      // The Hero sits outside `productAsync.when()`, keyed on the route's
      // `productId` (known synchronously), so it's mounted on frame one —
      // `productByIdProvider` is a FutureProvider, and a Hero nested only
      // inside its `data` branch wouldn't exist yet when GoRouter's push
      // transition starts its Hero scan, so the flight would silently never
      // fire. This guarantees the flight from `ProductCard` always triggers.
      body: Column(
        children: [
          Hero(
            tag: 'product-image-${widget.productId}',
            child: AspectRatio(
              aspectRatio: 1.2,
              child: productAsync.maybeWhen(
                data: (product) =>
                    product != null && product.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: product.imageUrl,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: isDark ? Colors.white12 : Colors.black12,
                        child: const Icon(Icons.image_outlined, size: 64),
                      ),
                orElse: () =>
                    Container(color: isDark ? Colors.white12 : Colors.black12),
              ),
            ),
          ),
          Expanded(
            child: productAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => ErrorStateWidget(
                onRetry: () =>
                    ref.invalidate(productByIdProvider(widget.productId)),
              ),
              data: (product) {
                if (product == null) {
                  return const ErrorStateWidget(
                    message: 'This product is no longer available.',
                  );
                }
                return _ProductDetailBody(
                  product: product,
                  qty: _qty ?? product.minQty,
                  onQtyChanged: (qty) => setState(() => _qty = qty),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductDetailBody extends ConsumerWidget {
  final ProductEntity product;
  final int qty;
  final ValueChanged<int> onQtyChanged;

  const _ProductDetailBody({
    required this.product,
    required this.qty,
    required this.onQtyChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Sold per ${product.unit.value}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        product.isWeighed
                            ? 'from ₹${product.rateSlabs!.bestRatePerKg.toStringAsFixed(0)}/kg'
                            : product.price.formatted,
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.isInStock
                            ? '${product.stock} ${product.unit.value} in stock'
                            : 'Out of stock',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: product.isInStock
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                      if (product.isWeighed) ...[
                        const SizedBox(height: 20),
                        RateSlabTable(
                          slabs: product.rateSlabs!,
                          activeGrams: qty,
                        ),
                        const SizedBox(height: 20),
                        WeightSelector(
                          grams: qty,
                          onChanged: onQtyChanged,
                          slabs: product.rateSlabs!,
                          maxGrams: product.maxQty,
                        ),
                      ],
                      if (product.description != null &&
                          product.description!.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Text(
                          'Description',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          product.description!,
                          style: GoogleFonts.inter(fontSize: 13, height: 1.5),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Row(
              children: [
                // Weighed products get their picker inline in the body next
                // to the rate card, where the band highlight makes sense —
                // so the bottom bar is just the add button.
                if (product.isInStock && !product.isWeighed) ...[
                  QtyStepper(
                    qty: qty,
                    onChanged: onQtyChanged,
                    min: 1,
                    max: product.stock,
                  ),
                  const SizedBox(width: 14),
                ],
                Expanded(
                  child: PrimaryButton(
                    label: product.isInStock
                        ? (product.isWeighed
                              ? 'Add ${formatGrams(qty)} · ${product.priceForQty(qty).formatted}'
                              : 'Add to Cart')
                        : 'Out of Stock',
                    icon: Icons.shopping_cart_outlined,
                    onPressed: product.isInStock
                        ? () {
                            ref
                                .read(cartControllerProvider.notifier)
                                .addItem(
                                  CartItemEntity(
                                    productId: product.id,
                                    name: product.name,
                                    imageUrl: product.imageUrl,
                                    unitPrice: product.price,
                                    unit: product.unit,
                                    qty: qty,
                                    rateSlabs: product.rateSlabs,
                                  ),
                                );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${product.name} added to cart'),
                              ),
                            );
                          }
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
