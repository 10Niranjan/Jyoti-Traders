import '../entities/notification_entity.dart';

/// Local-only — notification history never touches Firestore (phases.md
/// §5: "list of received FCM notifications stored locally in Hive").
abstract class NotificationRepository {
  Stream<List<NotificationEntity>> watchNotifications();

  Future<void> addNotification(NotificationEntity notification);

  Future<void> markAsRead(String id);

  Future<void> markAllAsRead();
}
