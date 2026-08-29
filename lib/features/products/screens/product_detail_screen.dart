import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/route_names.dart';
import '../../../domain/entities/cart_item_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../../shared/widgets/inline_toast.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/quantity_picker.dart';
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

  final _toastKey = GlobalKey<InlineToastState>();

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
                  toastKey: _toastKey,
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
  final GlobalKey<InlineToastState> toastKey;

  const _ProductDetailBody({
    required this.product,
    required this.qty,
    required this.onQtyChanged,
    required this.toastKey,
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
                      ],
                      if (product.isInStock) ...[
                        const SizedBox(height: 20),
                        QuantityPicker(
                          product: product,
                          qty: qty,
                          onChanged: onQtyChanged,
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InlineToast(key: toastKey),
                PrimaryButton(
                  label: product.isInStock
                      ? 'Add ${product.labelForQty(qty)} · ${product.priceForQty(qty).formatted}'
                      : 'Out of Stock',
                  icon: Icons.shopping_cart_outlined,
                  onPressed: (product.isInStock && qty >= product.minQty && qty <= product.maxQty)
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
                          // This screen sits above the shell, so its
                          // floating cart bar isn't here to tap — the
                          // toast carries the route to the cart. Pushed,
                          // not `go`, for the same reason as the category
                          // screen's cart bar: `go`-ing to the Cart tab
                          // would discard this pushed product page, leaving
                          // no way back to it.
                          toastKey.currentState?.show(
                            '${product.name} added to cart',
                            actionLabel: 'VIEW CART',
                            onAction: () => context.push(RouteNames.viewCart),
                          );
                        }
                      : null,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
