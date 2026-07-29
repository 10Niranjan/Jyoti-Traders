import 'package:equatable/equatable.dart';

/// A retailer's push-notification opt-ins. Stored on the account (not the
/// device) so preferences follow the retailer across devices and so the
/// admin-side sender can respect them. Every flag defaults to `true` —
/// existing accounts with no stored preferences must see today's
/// send-everything behaviour unchanged, not a silent opt-out.
class NotificationPreferencesEntity extends Equatable {
  final bool orderUpdates;
  final bool promotions;
  final bool lowStockAlerts;

  const NotificationPreferencesEntity({
    this.orderUpdates = true,
    this.promotions = true,
    this.lowStockAlerts = true,
  });

  static const NotificationPreferencesEntity defaults = NotificationPreferencesEntity();

  NotificationPreferencesEntity copyWith({
    bool? orderUpdates,
    bool? promotions,
    bool? lowStockAlerts,
  }) {
    return NotificationPreferencesEntity(
      orderUpdates: orderUpdates ?? this.orderUpdates,
      promotions: promotions ?? this.promotions,
      lowStockAlerts: lowStockAlerts ?? this.lowStockAlerts,
    );
  }

  @override
  List<Object?> get props => [orderUpdates, promotions, lowStockAlerts];
}
