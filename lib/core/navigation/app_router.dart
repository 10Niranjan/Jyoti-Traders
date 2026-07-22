import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../features/auth/controllers/auth_state.dart';
import '../../features/auth/screens/auth_screen.dart';
import '../../features/admin/screens/add_edit_category_screen.dart';
import '../../features/admin/screens/add_edit_product_screen.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/admin/screens/approval_queue_screen.dart';
import '../../features/admin/screens/all_orders_screen.dart';
import '../../features/admin/screens/manage_categories_screen.dart';
import '../../features/admin/screens/manage_products_screen.dart';
import '../../features/admin/screens/order_management_screen.dart';
import '../../features/admin/screens/retailer_list_screen.dart';
import '../../features/auth/screens/pending_approval_screen.dart';
import '../../features/cart/screens/cart_screen.dart';
import '../../features/checkout/screens/checkout_screen.dart';
import '../../features/checkout/screens/order_success_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/orders/screens/order_detail_screen.dart';
import '../../features/orders/screens/order_history_screen.dart';
import '../../features/products/screens/category_products_screen.dart';
import '../../features/products/screens/product_detail_screen.dart';
import '../../features/products/screens/search_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../shared/widgets/bottom_nav_bar.dart';
import '../constants/app_colors.dart';
import '../constants/route_names.dart';

/// Notifies GoRouter to re-run its `redirect` callback whenever auth state
/// changes, without recreating the `GoRouter` instance itself. Building a
/// brand-new `GoRouter` on every state change (e.g. via `ref.watch` at the
/// top of the provider) is a well-known anti-pattern that leaves navigation
/// stuck mid-transition — `MaterialApp.router` doesn't reliably resume a
/// swapped-out router's in-flight redirect.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen(authControllerProvider, (previous, next) => notifyListeners());
  }
}

// Router Provider — built exactly once; reacts to auth state via
// refreshListenable instead of rebuilding the whole GoRouter.
final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRefreshNotifier(ref);

  return GoRouter(
    initialLocation: RouteNames.splash,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final location = state.matchedLocation;

      // If we are still checking local token or auth status, wait on Splash
      if (authState is AuthInitial || authState is AuthLoading) {
        return location == RouteNames.splash ? null : RouteNames.splash;
      }

      // If user is not authenticated, force Auth screen
      if (authState is Unauthenticated || authState is AuthError) {
        return location == RouteNames.login ? null : RouteNames.login;
      }

      // If user is pending manual admin approval, restrict to Pending Screen
      if (authState is PendingApproval) {
        return location == RouteNames.pendingApproval ? null : RouteNames.pendingApproval;
      }

      // If user is Admin, route to Admin Panel
      if (authState is AuthenticatedAdmin) {
        final target = (location == RouteNames.splash || location == RouteNames.login || location == RouteNames.home || location == RouteNames.pendingApproval)
            ? RouteNames.admin
            : null;
        return target;
      }

      // If user is verified Customer/Retailer, route to Marketplace
      if (authState is AuthenticatedCustomer) {
        final target = (location == RouteNames.splash || location == RouteNames.login || location == RouteNames.admin || location == RouteNames.pendingApproval)
            ? RouteNames.home
            : null;
        return target;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: RouteNames.pendingApproval,
        builder: (context, state) => const PendingApprovalScreen(),
      ),
      GoRoute(
        path: RouteNames.admin,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: RouteNames.adminApprovalQueue,
        builder: (context, state) => const ApprovalQueueScreen(),
      ),
      GoRoute(
        path: RouteNames.adminProducts,
        builder: (context, state) => const ManageProductsScreen(),
      ),
      GoRoute(
        path: RouteNames.adminAddProduct,
        builder: (context, state) => const AddEditProductScreen(),
      ),
      GoRoute(
        path: RouteNames.adminEditProduct,
        builder: (context, state) => AddEditProductScreen(productId: state.pathParameters['productId']!),
      ),
      GoRoute(
        path: RouteNames.adminCategories,
        builder: (context, state) => const ManageCategoriesScreen(),
      ),
      GoRoute(
        path: RouteNames.adminAddCategory,
        builder: (context, state) => const AddEditCategoryScreen(),
      ),
      GoRoute(
        path: RouteNames.adminEditCategory,
        builder: (context, state) => AddEditCategoryScreen(categoryId: state.pathParameters['categoryId']!),
      ),
      GoRoute(
        path: RouteNames.adminOrders,
        builder: (context, state) => const AllOrdersScreen(),
      ),
      GoRoute(
        path: RouteNames.adminOrderManagement,
        builder: (context, state) => OrderManagementScreen(orderId: state.pathParameters['orderId']!),
      ),
      GoRoute(
        path: RouteNames.adminRetailers,
        builder: (context, state) => const RetailerListScreen(),
      ),
      GoRoute(
        path: RouteNames.adminRetailerOrders,
        builder: (context, state) => AllOrdersScreen(retailerId: state.pathParameters['retailerId']!),
      ),

      // Retailer bottom-nav shell — Home/Search/Cart/Orders/Profile keep
      // independent navigation state across tab switches.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => _RetailerShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: RouteNames.home, builder: (context, state) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: RouteNames.search, builder: (context, state) => const SearchScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: RouteNames.cart, builder: (context, state) => const CartScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: RouteNames.orders, builder: (context, state) => const OrderHistoryScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: RouteNames.profile, builder: (context, state) => const ProfileScreen()),
          ]),
        ],
      ),

      // Full-screen push routes on top of the shell (no bottom nav visible).
      GoRoute(
        path: RouteNames.productCategory,
        builder: (context, state) => CategoryProductsScreen(categoryId: state.pathParameters['categoryId']!),
      ),
      GoRoute(
        path: RouteNames.productDetail,
        builder: (context, state) => ProductDetailScreen(productId: state.pathParameters['productId']!),
      ),
      GoRoute(
        path: RouteNames.checkout,
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: RouteNames.orderSuccess,
        builder: (context, state) => OrderSuccessScreen(orderId: state.pathParameters['orderId']!),
      ),
      GoRoute(
        path: RouteNames.orderDetail,
        builder: (context, state) => OrderDetailScreen(orderId: state.pathParameters['orderId']!),
      ),
    ],
  );
});

class _RetailerShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _RetailerShell({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavBar(navigationShell: navigationShell),
    );
  }
}

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppColors.backgroundDark, const Color(0xFF070B19)]
                : [const Color(0xFFEFF6FF), AppColors.backgroundLight],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  size: 80,
                  color: AppColors.primary,
                ),
              ).animate(onPlay: (controller) {
                if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST')) return;
                controller.repeat(reverse: true);
              }).scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 1200.ms, curve: Curves.easeInOut),

              const SizedBox(height: 24),

              Text(
                'Jyoti Kirana',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
                  letterSpacing: 0.5,
                ),
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 8),

              Text(
                'Wholesale Market Store',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

              const SizedBox(height: 48),

              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
