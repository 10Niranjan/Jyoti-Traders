import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/route_names.dart';
import '../../../core/utils/weight_formatter.dart';
import '../../../domain/entities/cart_item_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import '../../cart/controllers/cart_controller.dart';
import '../controllers/search_controller.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchControllerProvider);
    final notifier = ref.read(searchControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search products...',
            border: InputBorder.none,
          ),
          onChanged: notifier.onQueryChanged,
          onSubmitted: notifier.commitToRecentSearches,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: state.query.trim().isEmpty
            ? _RecentSearches(
                terms: state.recentSearches,
                onTapTerm: (term) {
                  _controller.text = term;
                  notifier.onQueryChanged(term);
                },
                onClear: notifier.clearRecentSearches,
              )
            : _SearchResults(
                isLoading: state.isLoading,
                hasError: state.hasError,
                results: state.results,
                onRetry: notifier.retry,
                onResultTap: (product) {
                  notifier.commitToRecentSearches(state.query);
                  context.push(RouteNames.productDetailPath(product.id));
                },
              ),
      ),
    );
  }
}

class _RecentSearches extends StatelessWidget {
  final List<String> terms;
  final ValueChanged<String> onTapTerm;
  final VoidCallback onClear;

  const _RecentSearches({
    required this.terms,
    required this.onTapTerm,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (terms.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.search_rounded,
        title: 'Search for products',
        message: 'Try a product name like "rice" or "oil".',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Searches',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            TextButton(onPressed: onClear, child: const Text('Clear')),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: terms
              .map(
                (term) => ActionChip(
                  label: Text(term),
                  onPressed: () => onTapTerm(term),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _SearchResults extends StatelessWidget {
  final bool isLoading;
  final bool hasError;
  final List<ProductEntity> results;
  final Future<void> Function() onRetry;
  final ValueChanged<ProductEntity> onResultTap;

  const _SearchResults({
    required this.isLoading,
    required this.hasError,
    required this.results,
    required this.onRetry,
    required this.onResultTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const ListShimmerLoader(itemCount: 5);
    return RefreshIndicator(
      onRefresh: onRetry,
      child: hasError
          ? ListView(children: [ErrorStateWidget(onRetry: onRetry)])
          : results.isEmpty
          ? ListView(
              children: const [
                EmptyStateWidget(
                  icon: Icons.search_off_rounded,
                  title: 'No products found',
                ),
              ],
            )
          : Consumer(
              builder: (context, ref, _) => ListView.separated(
                itemCount: results.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final product = results[index];
                  return _SearchResultTile(
                    product: product,
                    onTap: () => onResultTap(product),
                    onAdd: () => ref
                        .read(cartControllerProvider.notifier)
                        .addItem(
                          CartItemEntity(
                            productId: product.id,
                            name: product.name,
                            imageUrl: product.imageUrl,
                            unitPrice: product.price,
                            unit: product.unit,
                            qty: product.isWeighed ? defaultAddGrams(product.maxQty) : 1,
                            rateSlabs: product.rateSlabs,
                          ),
                        ),
                  );
                },
              ),
            ),
    );
  }
}

/// A search result row — same card language as `_CartItemTile`/`ProductCard`
/// (rounded surface, real thumbnail, price in `AppColors.primary`) instead
/// of a bare default `ListTile`, so results don't look like a different app
/// from the rest of the catalog.
class _SearchResultTile extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  const _SearchResultTile({required this.product, required this.onTap, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isDark ? Colors.white12 : Colors.black12,
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: product.imageUrl.isEmpty
                  ? const Icon(Icons.image_outlined)
                  : CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => const Icon(Icons.image_outlined),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    // A weighed product's `price` is only its small-quantity
                    // band rate, not a real per-unit price — showing it flat
                    // (e.g. "₹260") reads as the product costing ₹260, not
                    // ₹260/kg. Same "from ₹x/kg" treatment as ProductCard.
                    product.isWeighed
                        ? 'from ₹${product.rateSlabs!.bestRatePerKg.toStringAsFixed(0)}/kg'
                        : product.price.formatted,
                    style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (!product.isInStock)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
              )
            else
              InkWell(
                onTap: onAdd,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
