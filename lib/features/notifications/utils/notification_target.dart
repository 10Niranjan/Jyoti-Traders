import '../../../core/constants/route_names.dart';
import '../../../domain/entities/notification_entity.dart';
import '../../auth/controllers/auth_state.dart';

/// Where tapping [notification] should navigate — `null` when it has no
/// linked order. The notification bell/list is shared across roles (both
/// Home and the Admin Dashboard show it, per-device not per-role — Phase 5),
/// so the destination depends on who's signed in right now, not on the
/// notification itself: the admin's editable order screen, or the
/// retailer's read-only one.
String? notificationTargetRoute(NotificationEntity notification, AuthState authState) {
  final orderId = notification.orderId;
  if (orderId == null) return null;
  return authState is AuthenticatedAdmin
      ? RouteNames.adminOrderManagementPath(orderId)
      : RouteNames.orderDetailPath(orderId);
}
