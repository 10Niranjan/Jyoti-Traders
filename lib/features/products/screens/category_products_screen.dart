import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/route_names.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../../shared/widgets/product_card.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import '../../home/controllers/home_controller.dart';
import '../controllers/product_controller.dart';

class CategoryProductsScreen extends ConsumerWidget {
  final String categoryId;

  const CategoryProductsScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsByCategoryProvider(categoryId));
    final categoriesAsync = ref.watch(categoriesProvider);

    final categoryName = categoriesAsync.maybeWhen(
      data: (categories) {
        final matches = categories.where((c) => c.id == categoryId);
        return matches.isEmpty ? null : matches.first.name;
      },
      orElse: () => null,
    );

    return Scaffold(
      appBar: AppBar(title: Text(categoryName ?? 'Products')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: productsAsync.when(
          loading: () => const GridShimmerLoader(),
          error: (error, stack) => ErrorStateWidget(
            onRetry: () => ref.invalidate(productsByCategoryProvider(categoryId)),
          ),
          data: (products) => _ProductGrid(products: products),
        ),
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  final List<ProductEntity> products;

  const _ProductGrid({required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.inventory_2_outlined,
        title: 'No products in this category yet',
      );
    }

    return GridView.builder(
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
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
