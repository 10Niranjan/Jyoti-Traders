import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../../../domain/entities/notification_entity.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/notification_controller.dart';
import '../utils/notification_target.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.notificationsTitle,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () =>
                  ref.read(notificationControllerProvider).markAllAsRead(),
              child: Text(l10n.notificationsMarkAllRead),
            ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(16.0),
          child: ListShimmerLoader(itemHeight: 72),
        ),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: ErrorStateWidget(
            message: l10n.notificationsLoadError(e.toString()),
            onRetry: () => ref.invalidate(notificationsProvider),
          ),
        ),
        data: (notifications) {
          if (notifications.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.notifications_none_rounded,
              title: l10n.notificationsEmptyTitle,
              message: l10n.notificationsEmptyMessage,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: notifications.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _NotificationTile(
                notification: notification,
                onTap: () {
                  ref
                      .read(notificationControllerProvider)
                      .markAsRead(notification.id);
                  final route = notificationTargetRoute(
                    notification,
                    ref.read(authControllerProvider),
                  );
                  if (route != null) context.push(route);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUnread = !notification.isRead;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUnread ? AppColors.primary.withOpacity(0.05) : null,
          border: Border.all(color: AppColors.primary.withOpacity(0.08)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isUnread)
              Container(
                margin: const EdgeInsets.only(top: 5, right: 10),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: GoogleFonts.inter(
                      fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                      fontSize: 13.5,
                    ),
                  ),
                  if (notification.body.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: GoogleFonts.inter(fontSize: 12.5),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    notification.receivedAt.timeAgo,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
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
