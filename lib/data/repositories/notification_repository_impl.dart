import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/local/notification_local_datasource.dart';
import '../models/notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationLocalDatasource _local;

  NotificationRepositoryImpl(this._local);

  @override
  Stream<List<NotificationEntity>> watchNotifications() {
    return _local.watchNotifications().map((list) => list.map((m) => m.toEntity()).toList());
  }

  @override
  Future<void> addNotification(NotificationEntity notification) {
    return _local.addNotification(NotificationModel.fromEntity(notification));
  }

  @override
  Future<void> markAsRead(String id) {
    return _local.markAsRead(id);
  }

  @override
  Future<void> markAllAsRead() {
    return _local.markAllAsRead();
  }
}
