import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../l10n/app_localizations.dart';

/// Bottom navigation for the 4 retailer tab branches (Home/Search/Orders/
/// Profile), used as the `StatefulShellRoute` shell's `navigationBar`. Cart
/// isn't a tab — it's reached via the shell's floating cart bar instead,
/// matching the Figma reference's nav shape.
class BottomNavBar extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const BottomNavBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.textSecondaryLight,
          ),
        ),
      ),
      child: NavigationBar(
      selectedIndex: navigationShell.currentIndex,
      indicatorColor: Colors.transparent,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: states.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.textSecondaryLight,
        ),
      ),
      onDestinationSelected: (index) => navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      ),
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.storefront_outlined),
          label: l10n.navHome,
        ),
        NavigationDestination(
          icon: const Icon(Icons.search_rounded),
          label: l10n.navSearch,
        ),
        NavigationDestination(
          icon: const Icon(Icons.receipt_long_outlined),
          label: l10n.navOrders,
        ),
        NavigationDestination(
          icon: const Icon(Icons.person_outline_rounded),
          label: l10n.navProfile,
        ),
      ],
      ),
    );
  }
}
