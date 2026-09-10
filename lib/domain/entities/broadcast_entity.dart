import 'package:equatable/equatable.dart';

/// An admin-authored message meant for every retailer — e.g. "New stock
/// arrived", "Price drop on rice" — distinct from a personal notification
/// like "your order was confirmed". Stored once, shared across every
/// account on the device (see `BroadcastRepository`'s own doc), then copied
/// into each retailer's own notification history the first time their
/// session sees it (`broadcastIngestionProvider`).
class BroadcastEntity extends Equatable {
  final String id;
  final String title;
  final String body;
  final DateTime sentAt;

  const BroadcastEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.sentAt,
  });

  @override
  List<Object?> get props => [id, title, body, sentAt];
}
