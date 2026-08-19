import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bottom navigation for the 5 admin tab branches (Dashboard/Orders/Catalog/
/// Retailers/Profile), used as the admin `StatefulShellRoute` shell's
/// `navigationBar` — same role as `BottomNavBar` on the retailer side.
class AdminBottomNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AdminBottomNavBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: navigationShell.currentIndex,
      onDestinationSelected: (index) => navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      ),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          label: 'Orders',
        ),
        NavigationDestination(
          icon: Icon(Icons.inventory_2_outlined),
          label: 'Catalog',
        ),
        NavigationDestination(
          icon: Icon(Icons.storefront_outlined),
          label: 'Retailers',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}
