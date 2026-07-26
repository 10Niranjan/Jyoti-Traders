import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
    final cartItemCount = ref.watch(
      cartControllerProvider.select((cart) => cart.itemCount),
    );

    return NavigationBar(
      selectedIndex: navigationShell.currentIndex,
      onDestinationSelected: (index) => navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      ),
      destinations: [
        const NavigationDestination(
          icon: Icon(Icons.storefront_outlined),
          label: 'Home',
        ),
        const NavigationDestination(
          icon: Icon(Icons.search_rounded),
          label: 'Search',
        ),
        NavigationDestination(
          // Keyed on `cartItemCount` so `Animate` restarts the bounce every
          // time the count actually changes (add/remove), not on every
          // unrelated rebuild — see flutter_animate's own `restartOnHotReload`
          // doc note on using a changing `key` to replay an effect.
          icon:
              badges.Badge(
                    showBadge: cartItemCount > 0,
                    badgeContent: Text(
                      '$cartItemCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    badgeStyle: const badges.BadgeStyle(
                      badgeColor: AppColors.error,
                    ),
                    child: const Icon(Icons.shopping_cart_outlined),
                  )
                  .animate(key: ValueKey(cartItemCount))
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.3, 1.3),
                    duration: 120.ms,
                    curve: Curves.easeOut,
                  )
                  .then()
                  .scale(
                    begin: const Offset(1.3, 1.3),
                    end: const Offset(1, 1),
                    duration: 150.ms,
                    curve: Curves.easeIn,
                  ),
          label: 'Cart',
        ),
        const NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          label: 'Orders',
        ),
        const NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}
