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
    return GridView.builder(
      itemCount: products.length,
      // Same fixed ratio CategoryProductsScreen settled on (0.68 clipped a
      // 2-line product name's fixed-height card).
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          onTap: () => context.push(RouteNames.productDetailPath(product.id)),
        );
      },
    );
  }
}
