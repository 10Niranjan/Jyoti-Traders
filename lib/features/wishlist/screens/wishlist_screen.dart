import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/route_names.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/product_card.dart';
import '../../../l10n/app_localizations.dart';
import '../controllers/wishlist_controller.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(wishlistProductsProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.wishlistTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: products.isEmpty
            ? ListView(
                children: [
                  EmptyStateWidget(
                    icon: Icons.favorite_border_rounded,
                    title: l10n.wishlistEmptyTitle,
                    message: l10n.wishlistEmptyMessage,
                  ),
                ],
              )
            : _WishlistGrid(products: products),
      ),
    );
  }
}

class _WishlistGrid extends StatelessWidget {
  final List<ProductEntity> products;

  const _WishlistGrid({required this.products});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) => GridView.builder(
        itemCount: products.length,
        // Card height tracks the Text size setting (see `productCardHeight`).
        gridDelegate: productGridDelegate(
          context,
          availableWidth: box.maxWidth,
        ),
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCard(
            product: product,
            onTap: () => context.push(RouteNames.productDetailPath(product.id)),
          );
        },
      ),
    );
  }
}
