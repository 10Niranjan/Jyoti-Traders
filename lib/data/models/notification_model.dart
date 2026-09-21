import '../../domain/entities/notification_entity.dart';

/// Hand-written, no codegen — stored as a plain Map in Hive, same approach
/// as every other locally-persisted model in this project (e.g. `CartItemModel`).
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String? orderId;
  final DateTime receivedAt;
  final bool isRead;
  final NotificationKind kind;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.orderId,
    required this.receivedAt,
    required this.isRead,
    this.kind = NotificationKind.general,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      orderId: json['orderId'] as String?,
      receivedAt: json['receivedAt'] as DateTime? ?? DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
      kind:
          NotificationKind.values.asNameMap()[json['kind']] ??
          NotificationKind.general,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'orderId': orderId,
    'receivedAt': receivedAt,
    'isRead': isRead,
    'kind': kind.name,
  };

  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      title: title,
      body: body,
      orderId: orderId,
      receivedAt: receivedAt,
      isRead: isRead,
      kind: kind,
    );
  }

  factory NotificationModel.fromEntity(NotificationEntity entity) {
    return NotificationModel(
      id: entity.id,
      title: entity.title,
      body: entity.body,
      orderId: entity.orderId,
      receivedAt: entity.receivedAt,
      isRead: entity.isRead,
      kind: entity.kind,
    );
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      body: body,
      orderId: orderId,
      receivedAt: receivedAt,
      isRead: isRead ?? this.isRead,
      kind: kind,
    );
  }
}
