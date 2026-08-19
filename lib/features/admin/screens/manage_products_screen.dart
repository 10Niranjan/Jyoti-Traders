import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/route_names.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import '../controllers/admin_product_controller.dart';
import '../widgets/admin_product_tile.dart';

/// Standalone screen at `/admin/products` — no longer linked to from
/// anywhere in-app since the Catalog tab (Phase 9.4) embeds [ProductsListView]
/// directly, but left in place (route + screen) as a working direct link.
class ManageProductsScreen extends StatelessWidget {
  const ManageProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Products',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: const AddProductFab(),
      body: const ProductsListView(),
    );
  }
}

/// Public so [CatalogScreen] (Phase 9.4) can also use it as the Products
/// segment's FAB.
class AddProductFab extends StatelessWidget {
  const AddProductFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => context.push(RouteNames.adminAddProduct),
      icon: const Icon(Icons.add_rounded),
      label: const Text('Add Product'),
    );
  }
}

/// The product list itself — no `Scaffold`/`AppBar`/FAB of its own, so it can
/// be embedded either inside [ManageProductsScreen] or, since Phase 9.4, as
/// one segment of the admin Catalog tab.
class ProductsListView extends ConsumerWidget {
  const ProductsListView({super.key});

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    ProductEntity product,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Delete product?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        content: Text(
          '"${product.name}" will be permanently removed from the catalog. '
          'To hide it from retailers without losing it, edit the product and turn off "Active" instead.',
          style: GoogleFonts.inter(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final success = await ref
        .read(adminProductControllerProvider.notifier)
        .delete(product.id);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '${product.name} deleted.'
              : 'Delete failed: ${ref.read(adminProductControllerProvider).error}',
        ),
        backgroundColor: success ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(allProductsProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(allProductsProvider),
      child: products.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(18.0),
          child: ListShimmerLoader(itemCount: 6, itemHeight: 92),
        ),
        error: (e, _) => ListView(
          padding: const EdgeInsets.all(18.0),
          children: [
            ErrorStateWidget(
              message: 'Couldn\'t load products: $e',
              onRetry: () => ref.invalidate(allProductsProvider),
            ),
          ],
        ),
        data: (list) {
          if (list.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(18.0),
              children: const [
                EmptyStateWidget(
                  icon: Icons.inventory_2_outlined,
                  title: 'No products yet',
                  message:
                      'Tap "Add Product" to create your first catalog item.',
                ),
              ],
            );
          }

          final lowStockCount = list
              .where((p) => p.stock <= AppConstants.kLowStockThreshold)
              .length;

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 88),
            itemCount: list.length + (lowStockCount > 0 ? 1 : 0),
            itemBuilder: (context, index) {
              if (lowStockCount > 0 && index == 0) {
                return _LowStockBanner(count: lowStockCount);
              }
              final product = list[index - (lowStockCount > 0 ? 1 : 0)];
              return AdminProductTile(
                product: product,
                onEdit: () =>
                    context.push(RouteNames.adminEditProductPath(product.id)),
                onDelete: () => _confirmDelete(context, ref, product),
              );
            },
          );
        },
      ),
    );
  }
}

class _LowStockBanner extends StatelessWidget {
  final int count;

  const _LowStockBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              count == 1
                  ? '1 product is low on stock (≤ ${AppConstants.kLowStockThreshold}).'
                  : '$count products are low on stock (≤ ${AppConstants.kLowStockThreshold}).',
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
