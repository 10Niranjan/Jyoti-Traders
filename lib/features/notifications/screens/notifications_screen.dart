import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/notification_grouping.dart';
import '../../../domain/entities/notification_entity.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import '../../../shared/widgets/staggered_entrance.dart';
import '../../../shared/widgets/status_filter_chip.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/notification_controller.dart';
import '../utils/notification_target.dart';
import '../widgets/notification_hero.dart';
import '../widgets/notification_tile.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _unreadOnly = false;

  String _sectionLabel(AppLocalizations l10n, NotificationDay day) {
    switch (day) {
      case NotificationDay.today:
        return l10n.notificationsSectionToday;
      case NotificationDay.yesterday:
        return l10n.notificationsSectionYesterday;
      case NotificationDay.thisWeek:
        return l10n.notificationsSectionThisWeek;
      case NotificationDay.earlier:
        return l10n.notificationsSectionEarlier;
    }
  }

  void _open(NotificationEntity notification) {
    ref.read(notificationControllerProvider).markAsRead(notification.id);
    final route = notificationTargetRoute(
      notification,
      ref.read(authControllerProvider),
    );
    if (route != null) context.push(route);
  }

  List<Widget> _rows(AppLocalizations l10n, List<NotificationEntity> all) {
    final unread = all.where((n) => !n.isRead).length;
    final visible = _unreadOnly ? all.where((n) => !n.isRead).toList() : all;
    var index = 0;

    final rows = <Widget>[
      StaggeredEntrance(
        index: index++,
        child: NotificationHero(
          unread: unread,
          total: all.length,
          onMarkAllRead: () =>
              ref.read(notificationControllerProvider).markAllAsRead(),
        ),
      ),
      const SizedBox(height: 18),
      StaggeredEntrance(
        index: index++,
        child: Row(
          children: [
            StatusFilterChip(
              label: l10n.notificationsFilterAll,
              selected: !_unreadOnly,
              onTap: () => setState(() => _unreadOnly = false),
            ),
            const SizedBox(width: 8),
            StatusFilterChip(
              label: l10n.notificationsFilterUnread(unread),
              selected: _unreadOnly,
              onTap: () => setState(() => _unreadOnly = true),
            ),
          ],
        ),
      ),
    ];

    if (visible.isEmpty) {
      rows.add(
        EmptyStateWidget(
          icon: Icons.done_all_rounded,
          title: l10n.notificationsUnreadEmptyTitle,
          message: l10n.notificationsUnreadEmptyMessage,
        ),
      );
      return rows;
    }

    for (final group in groupNotificationsByDay(visible)) {
      rows.add(
        _SectionHeader(
          label: _sectionLabel(l10n, group.day),
          count: group.items.length,
        ),
      );
      for (final notification in group.items) {
        rows.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: StaggeredEntrance(
              key: ValueKey(notification.id),
              index: index++,
              child: NotificationTile(
                notification: notification,
                onTap: () => _open(notification),
              ),
            ),
          ),
        );
      }
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.notificationsTitle,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
      ),
      body: notificationsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(16.0),
          child: ListShimmerLoader(itemHeight: 88),
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
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: _rows(l10n, notifications),
          );
        },
      ),
    );
  }
}

/// "TODAY ── 3": a small label, a hairline that fills the row, and a count.
class _SectionHeader extends StatelessWidget {
  final String label;
  final int count;

  const _SectionHeader({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 22, 4, 10),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Divider(height: 1, color: context.border)),
          const SizedBox(width: 10),
          Text(
            '$count',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
