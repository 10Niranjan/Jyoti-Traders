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
import '../../../shared/widgets/product_card.dart';
import '../../../shared/widgets/quantity_picker.dart';
import '../../../shared/widgets/weight_selector.dart';
import '../../../l10n/app_localizations.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../wishlist/controllers/wishlist_controller.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final isWishlisted = ref.watch(
      wishlistControllerProvider.select(
        (ids) => ids.contains(widget.productId),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.productDetailsTitle),
        actions: [
          IconButton(
            icon: Icon(
              isWishlisted
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: isWishlisted ? AppColors.error : null,
            ),
            tooltip: isWishlisted
                ? l10n.wishlistRemoveTooltip
                : l10n.wishlistAddTooltip,
            onPressed: () async {
              await ref
                  .read(wishlistControllerProvider.notifier)
                  .toggle(widget.productId);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isWishlisted ? l10n.wishlistRemoved : l10n.wishlistAdded,
                  ),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
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
                  return ErrorStateWidget(
                    message: l10n.productNoLongerAvailable,
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
    final l10n = AppLocalizations.of(context)!;

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
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.productSoldPer(product.unit.value),
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
                            ? l10n.homeFromRatePerKg(
                                product.rateSlabs!.bestRatePerKg
                                    .toStringAsFixed(0),
                              )
                            : product.price.formatted,
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.isInStock
                            ? l10n.productInStock(
                                product.stock,
                                product.unit.value,
                              )
                            : l10n.homeOutOfStock,
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
                          l10n.productDescription,
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
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
                _RelatedProductsRail(product: product),
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
                      ? l10n.productAddButtonLabel(
                          product.labelForQty(qty),
                          product.priceForQty(qty).formatted,
                        )
                      : l10n.productOutOfStockButton,
                  icon: Icons.shopping_cart_outlined,
                  onPressed:
                      (product.isInStock &&
                          qty >= product.minQty &&
                          qty <= product.maxQty)
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
                            l10n.productAddedToCart(product.name),
                            actionLabel: l10n.productViewCartAction,
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

/// Other active products from the same category, excluding this one —
/// reuses `ProductCard` as-is at a fixed rail width, the same trick Home's
/// Buy Again rail already established, rather than a new tile widget.
/// Renders nothing while the category is empty of other products.
class _RelatedProductsRail extends ConsumerWidget {
  final ProductEntity product;

  const _RelatedProductsRail({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(
      productsByCategoryProvider(product.categoryId),
    );
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return productsAsync.maybeWhen(
      data: (products) {
        final related = products
            .where((p) => p.id != product.id)
            .take(10)
            .toList();
        if (related.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.productYouMayAlsoLike,
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
                // Measured, not guessed — 246 overflowed ProductCard's
                // internal layout by half a pixel at this 150px rail width
                // (the same class of gap Home's own rail hit at Phase 9.7).
                height: 260,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: related.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final other = related[index];
                    return SizedBox(
                      width: 150,
                      child: ProductCard(
                        product: other,
                        onTap: () => context.push(
                          RouteNames.productDetailPath(other.id),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}
