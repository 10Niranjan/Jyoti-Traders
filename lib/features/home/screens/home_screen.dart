import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/route_names.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../shared/widgets/category_card.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../../shared/widgets/notification_bell_button.dart';
import '../../../shared/widgets/product_card.dart';
import '../../../shared/widgets/promo_banner_carousel.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/controllers/auth_state.dart';
import '../../notifications/controllers/stock_alert_controller.dart';
import '../controllers/home_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String name = 'Valued Customer';
    String business = 'Retailer';
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
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Owner: $name',
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
                'Browse Categories',
                style: GoogleFonts.poppins(
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
      return const EmptyStateWidget(
        icon: Icons.category_outlined,
        title: 'No categories yet',
        message: 'Check back soon — the admin is setting up the catalog.',
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
                  lowStock.length == 1
                      ? '1 of your regulars is low or out of stock.'
                      : '${lowStock.length} of your regulars are low or out of stock.',
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Buy Again',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 260,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final product = products[index];
                return SizedBox(
                  width: 150,
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
