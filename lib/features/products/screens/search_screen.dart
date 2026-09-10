import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_shadows.dart';
import '../../../core/constants/route_names.dart';
import '../../../core/utils/product_sort.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../shared/widgets/add_to_cart_pill.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../../shared/widgets/quantity_sheet.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import '../../../l10n/app_localizations.dart';
import '../../home/controllers/home_controller.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Container(
          height: 40,
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? Colors.white10 : AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                size: 20,
                color: AppColors.textSecondaryLight,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: l10n.searchHint,
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onChanged: (value) {
                    notifier.onQueryChanged(value);
                    setState(() {});
                  },
                  onSubmitted: notifier.commitToRecentSearches,
                ),
              ),
              if (_controller.text.isNotEmpty)
                InkWell(
                  onTap: () {
                    _controller.clear();
                    notifier.onQueryChanged('');
                    setState(() {});
                  },
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
            ],
          ),
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
                query: state.query,
                isLoading: state.isLoading,
                hasError: state.hasError,
                results: state.visibleResults,
                hasAnyResults: state.results.isNotEmpty,
                sort: state.sort,
                inStockOnly: state.inStockOnly,
                categoryIds: state.resultCategoryIds,
                selectedCategoryId: state.categoryId,
                onSortChanged: notifier.setSort,
                onInStockOnlyChanged: notifier.setInStockOnly,
                onCategoryChanged: notifier.setCategory,
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
    final l10n = AppLocalizations.of(context)!;
    if (terms.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.search_rounded,
        title: l10n.searchEmptyTitle,
        message: l10n.searchEmptyMessage,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.searchRecentSearches,
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            TextButton(onPressed: onClear, child: Text(l10n.searchClear)),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: terms
              .map(
                (term) => ActionChip(
                  label: Text(term),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  backgroundColor: Colors.white,
                  elevation: 0,
                  onPressed: () => onTapTerm(term),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _SearchResults extends ConsumerWidget {
  final String query;
  final bool isLoading;
  final bool hasError;
  final List<ProductEntity> results;
  final bool hasAnyResults;
  final ProductSort sort;
  final bool inStockOnly;
  final Set<String> categoryIds;
  final String? selectedCategoryId;
  final ValueChanged<ProductSort> onSortChanged;
  final ValueChanged<bool> onInStockOnlyChanged;
  final ValueChanged<String?> onCategoryChanged;
  final Future<void> Function() onRetry;
  final ValueChanged<ProductEntity> onResultTap;

  const _SearchResults({
    required this.query,
    required this.isLoading,
    required this.hasError,
    required this.results,
    required this.hasAnyResults,
    required this.sort,
    required this.inStockOnly,
    required this.categoryIds,
    required this.selectedCategoryId,
    required this.onSortChanged,
    required this.onInStockOnlyChanged,
    required this.onCategoryChanged,
    required this.onRetry,
    required this.onResultTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoading) return const ListShimmerLoader(itemCount: 5);
    final categoriesAsync = ref.watch(categoriesProvider);
    return Column(
      children: [
        if (!hasError && hasAnyResults && categoryIds.length > 1)
          categoriesAsync.maybeWhen(
            data: (categories) => _CategoryChipsRow(
              categories: categories
                  .where((c) => categoryIds.contains(c.id))
                  .toList(),
              selectedCategoryId: selectedCategoryId,
              onChanged: onCategoryChanged,
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        if (!hasError && hasAnyResults)
          _SortFilterBar(
            sort: sort,
            inStockOnly: inStockOnly,
            onSortChanged: onSortChanged,
            onInStockOnlyChanged: onInStockOnlyChanged,
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRetry,
            child: hasError
                ? ListView(children: [ErrorStateWidget(onRetry: onRetry)])
                : results.isEmpty
                ? ListView(
                    children: [
                      EmptyStateWidget(
                        icon: Icons.search_off_rounded,
                        title: AppLocalizations.of(
                          context,
                        )!.searchNoResultsFor(query),
                      ),
                    ],
                  )
                : ListView.separated(
                    itemCount: results.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final product = results[index];
                      return _SearchResultTile(
                        product: product,
                        onTap: () => onResultTap(product),
                        onAdd: () => showQuantitySheet(context, product),
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
          border: Border.all(color: AppColors.cardBorder),
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
