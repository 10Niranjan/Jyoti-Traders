import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/route_names.dart';
import '../../features/notifications/controllers/notification_controller.dart';
import '../../l10n/app_localizations.dart';

/// Bell icon with an unread-count badge, used in both the retailer
/// `HomeScreen` and `AdminDashboardScreen` app bars — notification history
/// is per-device, not per-role, so both point at the same screen.
class NotificationBellButton extends ConsumerWidget {
  const NotificationBellButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return IconButton(
      tooltip: AppLocalizations.of(context)!.notificationsTitle,
      icon: badges.Badge(
        showBadge: unreadCount > 0,
        badgeContent: Text(
          '$unreadCount',
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
        badgeStyle: const badges.BadgeStyle(badgeColor: AppColors.error),
        child: const Icon(Icons.notifications_outlined),
      ),
      onPressed: () => context.push(RouteNames.notifications),
    );
  }
}
