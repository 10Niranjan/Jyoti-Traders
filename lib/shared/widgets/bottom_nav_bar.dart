import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../features/cart/controllers/cart_controller.dart';

/// Bottom navigation for the 5 retailer tab branches (Home/Search/Cart/
/// Orders/Profile), used as the `StatefulShellRoute` shell's `navigationBar`.
class BottomNavBar extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const BottomNavBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItemCount = ref.watch(cartControllerProvider.select((cart) => cart.itemCount));

    return NavigationBar(
      selectedIndex: navigationShell.currentIndex,
      onDestinationSelected: (index) => navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      ),
      destinations: [
        const NavigationDestination(icon: Icon(Icons.storefront_outlined), label: 'Home'),
        const NavigationDestination(icon: Icon(Icons.search_rounded), label: 'Search'),
        NavigationDestination(
          icon: badges.Badge(
            showBadge: cartItemCount > 0,
            badgeContent: Text(
              '$cartItemCount',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            badgeStyle: const badges.BadgeStyle(badgeColor: AppColors.error),
            child: const Icon(Icons.shopping_cart_outlined),
          ),
          label: 'Cart',
        ),
        const NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Orders'),
        const NavigationDestination(icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
      ],
    );
  }
}
