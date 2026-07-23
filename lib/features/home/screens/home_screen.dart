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
import '../../../shared/widgets/promo_banner_carousel.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/controllers/auth_state.dart';
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
            Text(business, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(
              'Owner: $name',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        actions: [
          const NotificationBellButton(),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(categoriesProvider),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PromoBannerCarousel().animate().slideY(begin: 0.1, duration: 400.ms).fadeIn(),
              const SizedBox(height: 28),
              Text(
                'Browse Categories',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 12),
              categoriesAsync.when(
                loading: () => const GridShimmerLoader(crossAxisCount: 4, childAspectRatio: 0.85),
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
          onTap: () => context.push(RouteNames.productCategoryPath(category.id)),
        ).animate().scale(delay: (50 * index).ms, duration: 250.ms);
      },
    );
  }
}
