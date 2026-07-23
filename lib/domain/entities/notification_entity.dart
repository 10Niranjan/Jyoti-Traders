import 'package:equatable/equatable.dart';

/// A push notification received on this device — stored locally (Hive
/// only, per phases.md §5) so the retailer/admin can review past updates.
class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String body;
  final String? orderId;
  final DateTime receivedAt;
  final bool isRead;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    this.orderId,
    required this.receivedAt,
    required this.isRead,
  });

  NotificationEntity copyWith({bool? isRead}) {
    return NotificationEntity(
      id: id,
      title: title,
      body: body,
      orderId: orderId,
      receivedAt: receivedAt,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  List<Object?> get props => [id, title, body, orderId, receivedAt, isRead];
}
