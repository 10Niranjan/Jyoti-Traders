import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/fcm_service.dart';
import '../../../data/repositories/auth_repository_provider.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../domain/entities/notification_entity.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/controllers/auth_state.dart';

final fcmServiceProvider = Provider<FcmService>((ref) => FcmService());

/// Wires push notifications end-to-end: requests permission and fetches the
/// device token on first read, saves it to the signed-in user's profile
/// (again on every token rotation, and again on every login), and forwards
/// foreground messages into the local notification history.
///
/// A plain (non-autoDispose) `Provider<void>`, watched once from the app
/// root (`JyotiTradersApp`) so this initializes exactly once per app
/// lifetime — the `ref.watch` calls that follow read the cached value
/// rather than re-running the body.
final fcmInitializerProvider = Provider<void>((ref) {
  final fcm = ref.watch(fcmServiceProvider);
  final notificationRepo = ref.watch(notificationRepositoryProvider);

  Future<void> saveTokenForCurrentUser(String? token) async {
    if (token == null) return;
    final authState = ref.read(authControllerProvider);
    final uid = switch (authState) {
      AuthenticatedAdmin(:final user) => user.uid,
      AuthenticatedCustomer(:final user) => user.uid,
      _ => null,
    };
    if (uid == null) return;
    await ref
        .read(authRepositoryProvider)
        .updateFcmToken(uid: uid, fcmToken: token);
  }

  fcm.requestPermissionAndGetToken().then(saveTokenForCurrentUser);

  final tokenSub = fcm.onTokenRefresh.listen(saveTokenForCurrentUser);

  final messageSub = fcm.onForegroundMessage.listen((message) {
    notificationRepo.addNotification(
      NotificationEntity(
        id:
            message.messageId ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        title: message.notification?.title ?? 'Notification',
        body: message.notification?.body ?? '',
        orderId: message.data['orderId'] as String?,
        receivedAt: DateTime.now(),
        isRead: false,
      ),
    );
  });

  // Covers the case where the token was already fetched before login (e.g.
  // permission granted on the splash/auth screen) — re-save the moment the
  // user actually signs in.
  ref.listen(authControllerProvider, (previous, next) {
    if (next is AuthenticatedAdmin || next is AuthenticatedCustomer) {
      fcm.requestPermissionAndGetToken().then(saveTokenForCurrentUser);
    }
  });

  ref.onDispose(() {
    tokenSub.cancel();
    messageSub.cancel();
  });
});
