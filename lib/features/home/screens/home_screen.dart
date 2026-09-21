import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:badges/badges.dart' as badges;
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/route_names.dart';
import '../../../core/utils/extensions.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/order_entity.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/category_card.dart';
import '../../../shared/widgets/compact_product_tile.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../../shared/widgets/first_run_hint.dart';
import '../../../shared/widgets/notification_bell_button.dart';
import '../../../shared/widgets/product_card.dart';
import '../../../shared/widgets/promo_banner_carousel.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import '../../../shared/widgets/staggered_entrance.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/controllers/auth_state.dart';
import '../../notifications/controllers/stock_alert_controller.dart';
import '../../settings/widgets/settings_list.dart';
import '../../products/controllers/search_controller.dart';
import '../../products/widgets/search_field.dart';
import '../../products/widgets/search_results_view.dart';
import '../controllers/home_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final searching = ref.watch(
      searchControllerProvider.select((s) => s.query.trim().isNotEmpty),
    );

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
          badges.Badge(
            showBadge: !ref
                .watch(firstRunHintsProvider)
                .contains('home_wishlist_icon'),
            badgeStyle: const badges.BadgeStyle(
              badgeColor: AppColors.error,
              padding: EdgeInsets.all(4),
            ),
            position: badges.BadgePosition.topEnd(top: 4, end: 4),
            child: IconButton(
              icon: const Icon(Icons.favorite_border_rounded),
              tooltip: l10n.wishlistTitle,
              onPressed: () {
                ref
                    .read(firstRunHintsProvider.notifier)
                    .dismiss('home_wishlist_icon');
                context.push(RouteNames.wishlist);
              },
            ),
          ),
          const NotificationBellButton(),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            tooltip: l10n.profileLogOut,
            onPressed: () => confirmLogout(context, ref),
          ),
        ],
      ),
      // The search field is pinned above the content; typing swaps the home
      // sections for results in place instead of jumping to the Search tab.
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 12, 18, 4),
            child: SearchField(),
          ),
          Expanded(
            child: searching
                ? const Padding(
                    padding: EdgeInsets.fromLTRB(18, 12, 18, 0),
                    child: SearchResultsView(),
                  )
                : RefreshIndicator(
                    onRefresh: () async => ref.invalidate(categoriesProvider),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _ActiveOrderCard(),
                          if (authState is PendingApproval) ...[
                            const _PendingPreviewBanner(),
                            const SizedBox(height: 16),
                          ],
                          const PromoBannerCarousel()
                              .animate()
                              .slideY(begin: 0.1, duration: 400.ms)
                              .fadeIn(),
                          const SizedBox(height: 20),
                          const _LowStockBanner(),
                          const _TopProductsSection(),
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
                            data: (categories) =>
                                _CategoryGrid(categories: categories),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
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

/// Live strip for the retailer's newest in-progress order ("Order #A1B2C3D4
/// is out for delivery →"), opening its tracking page. Renders nothing when
/// no order is in flight.
class _ActiveOrderCard extends ConsumerWidget {
  const _ActiveOrderCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(activeOrderProvider);
    if (order == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final id = order.id.shortId;
    final (icon, message) = switch (order.orderStatus) {
      OrderStatus.pending => (
        Icons.hourglass_top_rounded,
        l10n.homeOrderPending(id),
      ),
      OrderStatus.confirmed => (
        Icons.check_circle_outline_rounded,
        l10n.homeOrderConfirmed(id),
      ),
      _ => (Icons.local_shipping_outlined, l10n.homeOrderOutForDelivery(id)),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => context.push(RouteNames.orderDetailPath(order.id)),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.25)),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.homeOrderTrack,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.primary,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shown only while the retailer's account is still pending admin approval —
/// they can browse the catalog (see the widened `PendingApproval` redirect
/// allow-list in `app_router.dart`), this just explains why Cart/Checkout
/// still bounce them back to the Pending screen.
class _PendingPreviewBanner extends StatelessWidget {
  const _PendingPreviewBanner();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.visibility_outlined,
            color: AppColors.warning,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.homePendingBanner,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.warning,
              ),
            ),
          ),
        ],
      ),
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

/// Admin-curated merchandising spot (`ProductEntity.isTopProduct`) — the
/// first product section on Home, ahead of the personalized Buy Again rail
/// and the category grid, matching the reference wholesale app's own
/// "Top Products" placement. A real 2-column grid via the shared
/// `ProductCard` (not a slimmed-down tile), same aspect ratio the category
/// product grid already uses. Renders nothing until the admin marks at
/// least one product — no awkward empty state during catalog setup.
class _TopProductsSection extends ConsumerWidget {
  const _TopProductsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(homeTopProductsProvider);
    if (products.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.homeTopProducts,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, box) => GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              // Card height tracks the Text size setting (see
              // `productCardHeight`), not a fixed ratio.
              gridDelegate: productGridDelegate(
                context,
                availableWidth: box.maxWidth,
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
          ),
        ],
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

    return FirstRunHint(
      hintId: 'home_buy_again_rail',
      message: l10n.firstRunHintBuyAgain,
      child: Padding(
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
                  return CompactProductTile(
                    product: product,
                    onTap: () =>
                        context.push(RouteNames.productDetailPath(product.id)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
