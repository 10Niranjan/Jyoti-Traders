import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_shadows.dart';
import '../../../core/constants/route_names.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/add_to_cart_pill.dart';
import '../../../shared/widgets/category_card.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../../shared/widgets/notification_bell_button.dart';
import '../../../shared/widgets/promo_banner_carousel.dart';
import '../../../shared/widgets/qty_stepper.dart';
import '../../../shared/widgets/quantity_sheet.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/controllers/auth_state.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../notifications/controllers/stock_alert_controller.dart';
import '../controllers/home_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    String name = l10n.homeDefaultCustomerName;
    String business = l10n.homeDefaultBusinessName;
    if (authState is AuthenticatedCustomer) {
      name = authState.user.name;
      business = authState.user.businessName;
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              business,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              l10n.homeOwnerLabel(name),
              style: GoogleFonts.inter(
                fontSize: 12,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        actions: [
          const NotificationBellButton(),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(categoriesProvider),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PromoBannerCarousel()
                  .animate()
                  .slideY(begin: 0.1, duration: 400.ms)
                  .fadeIn(),
              const SizedBox(height: 20),
              const _LowStockBanner(),
              const _BuyAgainRail(),
              Text(
                l10n.homeBrowseCategories,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 12),
              categoriesAsync.when(
                loading: () => const GridShimmerLoader(
                  crossAxisCount: 4,
                  childAspectRatio: 0.85,
                ),
                error: (error, stack) => ErrorStateWidget(
                  onRetry: () => ref.invalidate(categoriesProvider),
                ),
                data: (categories) => _CategoryGrid(categories: categories),
              ),
              const SizedBox(height: 12),
              const _TodaysPicksSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  final List<CategoryEntity> categories;

  const _CategoryGrid({required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      return EmptyStateWidget(
        icon: Icons.category_outlined,
        title: l10n.homeNoCategoriesTitle,
        message: l10n.homeNoCategoriesMessage,
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.85,
        crossAxisSpacing: 10,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final category = categories[index];
        return CategoryCard(
          category: category,
          onTap: () =>
              context.push(RouteNames.productCategoryPath(category.id)),
        ).animate().scale(delay: (50 * index).ms, duration: 250.ms);
      },
    );
  }
}

/// Heads-up when one of the retailer's own frequently-bought products is
/// low/out of stock — the same data that drives the local stock-alert
/// notification (Post-Launch Feature Additions), surfaced a layer higher so
/// it's visible without opening Notifications. Renders nothing when clear.
class _LowStockBanner extends ConsumerWidget {
  const _LowStockBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lowStock = ref.watch(lowStockFrequentProductsProvider);
    if (lowStock.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: () => context.push(RouteNames.notifications),
        borderRadius: BorderRadius.circular(12),
        child: Container(
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
                  l10n.homeLowStockBanner(lowStock.length),
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.error,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Horizontal quick-add rail for products the retailer orders often (≥2 past
/// orders — same threshold the stock alert uses). Reuses `ProductCard`
/// as-is, sized down with a fixed width the same way its own grid usage
/// constrains it — the card was already built to work at any width.
/// Renders nothing for a new retailer with no order history yet.
class _BuyAgainRail extends ConsumerWidget {
  const _BuyAgainRail();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(frequentlyBoughtProductsProvider);
    if (products.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.homeBuyAgain,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 196,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final product = products[index];
                return _BuyAgainTile(
                  product: product,
                  onTap: () =>
                      context.push(RouteNames.productDetailPath(product.id)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact "Buy Again" tile — a smaller image and a single-line add/stepper
/// row rather than the full grid `ProductCard`, matching the Figma
/// reference's slimmer horizontal rail treatment for this rail specifically.
class _BuyAgainTile extends ConsumerWidget {
  final ProductEntity product;
  final VoidCallback onTap;

  const _BuyAgainTile({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final qtyInCart = ref.watch(
      cartControllerProvider.select((cart) => cart.qtyFor(product.id)),
    );
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.08)),
          boxShadow: isDark ? null : AppShadows.card,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 96,
              width: double.infinity,
              child: product.imageUrl.isEmpty
                  ? Container(
                      color: isDark ? Colors.white12 : Colors.black12,
                      child: const Icon(Icons.image_outlined, size: 28),
                    )
                  : CachedNetworkImage(imageUrl: product.imageUrl, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.isWeighed
                        ? l10n.homeFromRatePerKg(product.rateSlabs!.bestRatePerKg.toStringAsFixed(0))
                        : product.price.formatted,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (!product.isInStock)
                    OutOfStockPill(isDark: isDark)
                  else if (qtyInCart == 0)
                    AddToCartPill(onTap: () => showQuantitySheet(context, product))
                  else
                    QtyStepper(
                      qty: qtyInCart,
                      max: product.maxQty,
                      onChanged: (qty) =>
                          ref.read(cartControllerProvider.notifier).updateQty(product.id, qty),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A short "browse the catalog" list — the first few active products,
/// matching the Figma reference's "Today's Picks" section. Distinct from
/// "Buy Again" (which only ever shows products this retailer has actually
/// reordered): this is just a generic catalog preview for a new retailer
/// with no order history yet, or anyone browsing beyond their regulars.
class _TodaysPicksSection extends ConsumerWidget {
  const _TodaysPicksSection();

  static const _maxPicks = 4;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(allActiveProductsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return productsAsync.maybeWhen(
      data: (products) {
        if (products.isEmpty) return const SizedBox.shrink();
        final picks = products.take(_maxPicks).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.homeTodaysPicks,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 12),
            for (final product in picks) ...[
              _TodaysPickTile(
                product: product,
                onTap: () => context.push(RouteNames.productDetailPath(product.id)),
              ),
              const SizedBox(height: 10),
            ],
          ],
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _TodaysPickTile extends ConsumerWidget {
  final ProductEntity product;
  final VoidCallback onTap;

  const _TodaysPickTile({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final qtyInCart = ref.watch(
      cartControllerProvider.select((cart) => cart.qtyFor(product.id)),
    );
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.08)),
          boxShadow: isDark ? null : AppShadows.card,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 52,
              height: 52,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: product.imageUrl.isEmpty
                    ? Container(
                        color: isDark ? Colors.white12 : Colors.black12,
                        child: const Icon(Icons.image_outlined),
                      )
                    : CachedNetworkImage(imageUrl: product.imageUrl, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.isWeighed
                        ? l10n.homeFromRatePerKg(product.rateSlabs!.bestRatePerKg.toStringAsFixed(0))
                        : product.price.formatted,
                    style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  if (!product.isInStock)
                    Text(
                      l10n.homeOutOfStock,
                      style: GoogleFonts.inter(fontSize: 10.5, color: AppColors.error),
                    )
                  else if (product.stock <= AppConstants.kLowStockThreshold)
                    Text(
                      l10n.homeOnlyLeftInStock(product.stock, product.unit.value),
                      style: GoogleFonts.inter(fontSize: 10.5, color: AppColors.warning),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (!product.isInStock)
              OutOfStockPill(isDark: isDark)
            else if (qtyInCart == 0)
              AddToCartPill(onTap: () => showQuantitySheet(context, product))
            else
              QtyStepper(
                qty: qtyInCart,
                max: product.maxQty,
                onChanged: (qty) => ref.read(cartControllerProvider.notifier).updateQty(product.id, qty),
              ),
          ],
        ),
      ),
    );
  }
}
