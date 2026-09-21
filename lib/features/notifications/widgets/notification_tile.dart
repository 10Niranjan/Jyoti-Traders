import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/extensions.dart';
import '../../../domain/entities/notification_entity.dart';
import '../../../l10n/app_localizations.dart';

/// Icon + colour for each kind of notification, so the inbox can be scanned
/// by colour before a single word is read.
({IconData icon, Color color}) notificationStyleFor(NotificationKind kind) {
  switch (kind) {
    case NotificationKind.order:
      return (icon: Icons.receipt_long_rounded, color: AppColors.primary);
    case NotificationKind.stock:
      return (icon: Icons.inventory_2_rounded, color: AppColors.warning);
    case NotificationKind.broadcast:
      // Teal from the category palette — the one cool note in a warm inbox.
      return (
        icon: Icons.campaign_rounded,
        color: AppColors.categoryPalette[2],
      );
    case NotificationKind.general:
      return (icon: Icons.notifications_rounded, color: AppColors.accent);
  }
}

/// One notification: a coloured icon tile, the title and time on one line, the
/// message, and — for order updates — a "View order" cue. Unread ones are
/// tinted and carry an accent edge in the same colour as their icon.
class NotificationTile extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isUnread = !notification.isRead;
    final style = notificationStyleFor(notification.displayKind);
    final color = style.color;

    return Container(
      // A real card (surface + a border you can see); unread adds a tint of
      // the kind's own colour plus the edge bar below.
      decoration: context.cardDecoration(
        radius: 18,
        color: isUnread
            ? Color.alphaBlend(color.withOpacity(0.07), context.surface)
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              if (isUnread)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 4,
                  child: ColoredBox(color: color),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            color.withOpacity(isUnread ? 0.28 : 0.17),
                            color.withOpacity(isUnread ? 0.12 : 0.07),
                          ],
                        ),
                        border: Border.all(
                          color: color.withOpacity(isUnread ? 0.34 : 0.18),
                        ),
                      ),
                      child: Icon(style.icon, size: 24, color: color),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  notification.title,
                                  style: GoogleFonts.inter(
                                    fontWeight: isUnread
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    fontSize: 15.5,
                                    height: 1.25,
                                    color: context.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: context.inset,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  notification.receivedAt.timeAgo,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: context.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (notification.body.isNotEmpty) ...[
                            const SizedBox(height: 5),
                            Text(
                              notification.body,
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                height: 1.4,
                                color: context.textSecondary,
                              ),
                            ),
                          ],
                          if (notification.orderId != null) ...[
                            const SizedBox(height: 10),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  l10n.notificationsViewOrder,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
