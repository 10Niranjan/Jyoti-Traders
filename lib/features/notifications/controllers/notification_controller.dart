import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../domain/entities/notification_entity.dart';
import '../../../domain/repositories/notification_repository.dart';

final notificationsProvider = StreamProvider.autoDispose<List<NotificationEntity>>((ref) {
  return ref.watch(notificationRepositoryProvider).watchNotifications();
});

/// Derived from the same stream rather than a separate query — every
/// notification is already loaded for the list screen.
final unreadNotificationCountProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(notificationsProvider).valueOrNull?.where((n) => !n.isRead).length ?? 0;
});

class NotificationController {
  final NotificationRepository _repository;

  NotificationController(this._repository);

  Future<void> markAsRead(String id) => _repository.markAsRead(id);

  Future<void> markAllAsRead() => _repository.markAllAsRead();
}

final notificationControllerProvider = Provider.autoDispose<NotificationController>((ref) {
  return NotificationController(ref.watch(notificationRepositoryProvider));
});
