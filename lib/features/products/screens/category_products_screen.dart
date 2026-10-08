import 'package:flutter/material.dart';
import '../../../core/theme/theme_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/route_names.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../shared/widgets/category_card.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../../shared/widgets/floating_cart_bar.dart';
import '../../../shared/widgets/product_card.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import '../../../shared/widgets/staggered_entrance.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../controllers/product_controller.dart';

/// Height of one rail entry ([CategoryCard]'s 56 dp ring + a 2-line name +
/// padding). Fixed so the rail can jump straight to the selected entry.
const double _kRailItemExtent = 112;
const double _kRailWidth = 76;

class CategoryProductsScreen extends ConsumerStatefulWidget {
  final String categoryId;

  const CategoryProductsScreen({super.key, required this.categoryId});

  @override
  ConsumerState<CategoryProductsScreen> createState() =>
      _CategoryProductsScreenState();
}

class _CategoryProductsScreenState
    extends ConsumerState<CategoryProductsScreen> {
  /// The category being shown. Starts as the route's id, then changes in place
  /// when the retailer taps another category in the rail — no new route, so
  /// Back still returns to wherever they came from, not through every
  /// category they hopped between.
  late String _categoryId = widget.categoryId;

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsByCategoryProvider(_categoryId));
    final categoriesAsync = ref.watch(categoriesProvider);
    final cart = ref.watch(cartControllerProvider);
    final categories = categoriesAsync.valueOrNull ?? const <CategoryEntity>[];
    final showRail = categories.length > 1;

    final categoryName = () {
      final matches = categories.where((c) => c.id == _categoryId);
      return matches.isEmpty ? null : matches.first.name;
    }();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          categoryName ??
              AppLocalizations.of(context)!.categoryProductsFallbackTitle,
        ),
      ),
      // This screen is pushed *on top of* the retailer shell, so the shell's
      // own floating cart bar isn't on screen here — and this is the one
      // screen where "+" lives. Hosting it as `bottomNavigationBar` lets
      // Scaffold reserve the space, so it can't overlap the last grid row.
      bottomNavigationBar: cart.isEmpty
          ? null
          : SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: FloatingCartBar(
                  cart: cart,
                  // Pushed, not `go` — this screen is itself a pushed route,
                  // and `go`-ing to the Cart tab would discard it, leaving no
                  // way back to this category except re-navigating from Home.
                  onTap: () => context.push(RouteNames.viewCart),
                ),
              ),
            ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showRail)
            _CategoryRail(
              categories: categories,
              selectedId: _categoryId,
              onSelected: (id) => setState(() => _categoryId = id),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async =>
                  ref.invalidate(productsByCategoryProvider(_categoryId)),
              child: Padding(
                padding: EdgeInsets.all(showRail ? 8 : 16),
                child: productsAsync.when(
                  loading: () => const GridShimmerLoader(),
                  error: (error, stack) => ListView(
                    children: [
                      ErrorStateWidget(
                        onRetry: () => ref.invalidate(
                          productsByCategoryProvider(_categoryId),
                        ),
                      ),
                    ],
                  ),
                  data: (products) => _ProductGrid(
                    // Keyed on the category so switching replays the grid's
                    // entrance instead of reusing the previous category's
                    // (already-played) animations.
                    key: ValueKey(_categoryId),
                    products: products,
                    narrow: showRail,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Left-hand column of category icons — one tap to another category without
/// going back to Home. Reuses [CategoryCard] as-is (same ring colour and
/// admin-uploaded icon as the Home grid); only the selection chrome is new.
class _CategoryRail extends StatefulWidget {
  final List<CategoryEntity> categories;
  final String selectedId;
  final ValueChanged<String> onSelected;

  const _CategoryRail({
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  State<_CategoryRail> createState() => _CategoryRailState();
}

class _CategoryRailState extends State<_CategoryRail> {
  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    // Start with the selected category in view — with a dozen categories the
    // one the retailer just tapped on Home can be well below the fold.
    final index = widget.categories.indexWhere(
      (c) => c.id == widget.selectedId,
    );
    _scroll = ScrollController(
      initialScrollOffset: index <= 0 ? 0 : (index - 1) * _kRailItemExtent,
    );
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: _kRailWidth,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
        border: Border(right: BorderSide(color: context.border)),
      ),
      child: ListView.builder(
        controller: _scroll,
        itemExtent: _kRailItemExtent,
        itemCount: widget.categories.length,
        itemBuilder: (context, index) {
          final category = widget.categories[index];
          final selected = category.id == widget.selectedId;
          return Container(
            decoration: BoxDecoration(
              color: selected ? AppColors.primary.withOpacity(0.08) : null,
              border: Border(
                left: BorderSide(
                  width: 3,
                  color: selected ? AppColors.primary : Colors.transparent,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: CategoryCard(
              category: category,
              onTap: () => widget.onSelected(category.id),
            ),
          );
        },
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  final List<ProductEntity> products;

  /// Squeezed beside the category rail: tighter spacing (the cards themselves
  /// adapt to their width).
  final bool narrow;

  const _ProductGrid({super.key, required this.products, required this.narrow});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return ListView(
        children: [
          EmptyStateWidget(
            icon: Icons.inventory_2_outlined,
            title: AppLocalizations.of(context)!.categoryProductsEmptyTitle,
          ),
        ],
      );
    }

    // Card height comes from `productCardHeight` (image + a text block that
    // grows with the Text size setting), not a fixed ratio — a ratio tuned at
    // 1.0x text (0.62; 0.68 before it clipped 2-line names) clips the price/ADD
    // row once text is scaled up.
    return LayoutBuilder(
      builder: (context, box) => GridView.builder(
        itemCount: products.length,
        gridDelegate: productGridDelegate(
          context,
          availableWidth: box.maxWidth,
          spacing: narrow ? 8 : 12,
        ),
        itemBuilder: (context, index) {
          final product = products[index];
          return StaggeredEntrance(
            key: ValueKey(product.id),
            index: index,
            child: ProductCard(
              product: product,
              onTap: () =>
                  context.push(RouteNames.productDetailPath(product.id)),
            ),
          );
        },
      ),
    );
  }
}
