import 'package:equatable/equatable.dart';

/// What a notification is about — drives its icon and colour in the inbox.
/// Stored by name; anything unrecognised (or saved before this existed)
/// reads back as [general].
enum NotificationKind { general, order, stock, broadcast }

/// A push notification received on this device — stored locally (Hive
/// only, per phases.md §5) so the retailer/admin can review past updates.
class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String body;
  final String? orderId;
  final DateTime receivedAt;
  final bool isRead;
  final NotificationKind kind;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    this.orderId,
    required this.receivedAt,
    required this.isRead,
    this.kind = NotificationKind.general,
  });

  /// [kind], except that anything carrying an order id is an order update —
  /// notifications saved before [kind] existed have no kind, only an orderId.
  NotificationKind get displayKind =>
      kind == NotificationKind.general && orderId != null
      ? NotificationKind.order
      : kind;

  NotificationEntity copyWith({bool? isRead}) {
    return NotificationEntity(
      id: id,
      title: title,
      body: body,
      orderId: orderId,
      receivedAt: receivedAt,
      isRead: isRead ?? this.isRead,
      kind: kind,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    body,
    orderId,
    receivedAt,
    isRead,
    kind,
  ];
}
