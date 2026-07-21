import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/cart_item_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/qty_stepper.dart';
import '../../cart/controllers/cart_controller.dart';
import '../controllers/product_controller.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _qty = 1;

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productByIdProvider(widget.productId));

    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: productAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => ErrorStateWidget(
          onRetry: () => ref.invalidate(productByIdProvider(widget.productId)),
        ),
        data: (product) {
          if (product == null) {
            return const ErrorStateWidget(message: 'This product is no longer available.');
          }
          return _ProductDetailBody(
            product: product,
            qty: _qty,
            onQtyChanged: (qty) => setState(() => _qty = qty),
          );
        },
      ),
    );
  }
}

class _ProductDetailBody extends ConsumerWidget {
  final ProductEntity product;
  final int qty;
  final ValueChanged<int> onQtyChanged;

  const _ProductDetailBody({required this.product, required this.qty, required this.onQtyChanged});

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
                AspectRatio(
                  aspectRatio: 1.2,
                  child: product.imageUrl.isEmpty
                      ? Container(
                          color: isDark ? Colors.white12 : Colors.black12,
                          child: const Icon(Icons.image_outlined, size: 64),
                        )
                      : CachedNetworkImage(imageUrl: product.imageUrl, fit: BoxFit.cover),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Sold per ${product.unit.value}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        product.price.formatted,
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.isInStock ? '${product.stock} in stock' : 'Out of stock',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: product.isInStock ? AppColors.success : AppColors.error,
                        ),
                      ),
                      if (product.description != null && product.description!.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Text('Description', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text(product.description!, style: GoogleFonts.inter(fontSize: 13, height: 1.5)),
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
                if (product.isInStock) QtyStepper(qty: qty, onChanged: onQtyChanged, min: 1, max: product.stock),
                const SizedBox(width: 14),
                Expanded(
                  child: PrimaryButton(
                    label: product.isInStock ? 'Add to Cart' : 'Out of Stock',
                    icon: Icons.shopping_cart_outlined,
                    onPressed: product.isInStock
                        ? () {
                            ref.read(cartControllerProvider.notifier).addItem(
                                  CartItemEntity(
                                    productId: product.id,
                                    name: product.name,
                                    imageUrl: product.imageUrl,
                                    unitPrice: product.price,
                                    unit: product.unit,
                                    qty: qty,
                                  ),
                                );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${product.name} added to cart')),
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
