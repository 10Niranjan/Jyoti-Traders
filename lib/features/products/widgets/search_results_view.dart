import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/theme_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_shadows.dart';
import '../../../core/constants/route_names.dart';
import '../../../core/utils/product_sort.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/add_to_cart_pill.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../../shared/widgets/quantity_sheet.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import '../../../shared/widgets/staggered_entrance.dart';
import '../../home/controllers/home_controller.dart';
import '../controllers/search_controller.dart';

/// Results for the current `searchControllerProvider` query — shimmer while
/// loading, error/empty states, category chips, sort/filter bar and the
/// result list. Shared by the Search tab and Home's inline search so the two
/// can't drift apart.
class SearchResultsView extends ConsumerWidget {
  const SearchResultsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchControllerProvider);
    final notifier = ref.read(searchControllerProvider.notifier);
    if (state.isLoading) return const ListShimmerLoader(itemCount: 5);

    final results = state.visibleResults;
    final hasAnyResults = state.results.isNotEmpty;
    final categoriesAsync = ref.watch(categoriesProvider);
    return Column(
      children: [
        if (!state.hasError &&
            hasAnyResults &&
            state.resultCategoryIds.length > 1)
          categoriesAsync.maybeWhen(
            data: (categories) => _CategoryChipsRow(
              categories: categories
                  .where((c) => state.resultCategoryIds.contains(c.id))
                  .toList(),
              selectedCategoryId: state.categoryId,
              onChanged: notifier.setCategory,
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        if (!state.hasError && hasAnyResults)
          _SortFilterBar(
            sort: state.sort,
            inStockOnly: state.inStockOnly,
            onSortChanged: notifier.setSort,
            onInStockOnlyChanged: notifier.setInStockOnly,
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: notifier.retry,
            child: state.hasError
                ? ListView(children: [ErrorStateWidget(onRetry: notifier.retry)])
                : results.isEmpty
                ? ListView(
                    children: [
                      EmptyStateWidget(
                        icon: Icons.search_off_rounded,
                        title: AppLocalizations.of(
                          context,
                        )!.searchNoResultsFor(state.query),
                      ),
                    ],
                  )
                : ListView.separated(
                    itemCount: results.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final product = results[index];
                      return StaggeredEntrance(
                        key: ValueKey(product.id),
                        index: index,
                        child: _SearchResultTile(
                          product: product,
                          onTap: () {
                            notifier.commitToRecentSearches(state.query);
                            context.push(
                              RouteNames.productDetailPath(product.id),
                            );
                          },
                          onAdd: () => showQuantitySheet(context, product),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

/// "All" + one chip per category this specific search actually spans (never
/// the full app catalog — a query matching only 2 categories shouldn't offer
/// 8 empty ones). Only rendered by the caller when there's more than one
/// category to choose between.
class _CategoryChipsRow extends StatelessWidget {
  final List<CategoryEntity> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onChanged;

  const _CategoryChipsRow({
    required this.categories,
    required this.selectedCategoryId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ChoiceChip(
              label: Text(l10n.searchAllCategories),
              selected: selectedCategoryId == null,
              onSelected: (_) => onChanged(null),
            ),
            for (final category in categories) ...[
              const SizedBox(width: 8),
              ChoiceChip(
                label: Text(category.name),
                selected: selectedCategoryId == category.id,
                onSelected: (_) => onChanged(category.id),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Sort dropdown + in-stock-only toggle, shown above results whenever the
/// raw search returned something to sort/filter — kept visible even if the
/// current filter combination empties the visible list, so "In stock only"
/// can be switched back off.
class _SortFilterBar extends StatelessWidget {
  final ProductSort sort;
  final bool inStockOnly;
  final ValueChanged<ProductSort> onSortChanged;
  final ValueChanged<bool> onInStockOnlyChanged;

  const _SortFilterBar({
    required this.sort,
    required this.inStockOnly,
    required this.onSortChanged,
    required this.onInStockOnlyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<ProductSort>(
                value: sort,
                isDense: true,
                icon: const Icon(Icons.sort_rounded, size: 18),
                items: [
                  DropdownMenuItem(
                    value: ProductSort.relevance,
                    child: Text(l10n.searchSortRelevance),
                  ),
                  DropdownMenuItem(
                    value: ProductSort.priceLowToHigh,
                    child: Text(l10n.searchSortPriceLowToHigh),
                  ),
                  DropdownMenuItem(
                    value: ProductSort.priceHighToLow,
                    child: Text(l10n.searchSortPriceHighToLow),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) onSortChanged(value);
                },
              ),
            ),
          ),
          FilterChip(
            label: Text(
              l10n.searchInStockOnly,
              style: GoogleFonts.inter(fontSize: 12),
            ),
            selected: inStockOnly,
            onSelected: onInStockOnlyChanged,
          ),
        ],
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

  const _SearchResultTile({
    required this.product,
    required this.onTap,
    required this.onAdd,
  });

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
          border: Border.all(color: context.border),
          boxShadow: isDark ? null : AppShadows.card,
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
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.image_outlined),
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
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    // A weighed product's `price` is only its small-quantity
                    // band rate, not a real per-unit price — showing it flat
                    // (e.g. "₹260") reads as the product costing ₹260, not
                    // ₹260/kg. Same "from ₹x/kg" treatment as ProductCard.
                    product.isWeighed
                        ? AppLocalizations.of(context)!.homeFromRatePerKg(
                            product.rateSlabs!.bestRatePerKg.toStringAsFixed(0),
                          )
                        : product.price.formatted,
                    style: GoogleFonts.inter(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (!product.isInStock)
              OutOfStockPill(isDark: isDark)
            else
              AddToCartPill(filled: true, onTap: onAdd),
          ],
        ),
      ),
    );
  }
}
