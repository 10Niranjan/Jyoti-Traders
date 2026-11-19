import '../constants/app_constants.dart';

enum DeliveryEta { today, tomorrow, fewDays, unknown }

/// A same-fleet delivery promise derived from distance to the warehouse —
/// this app has no external logistics API, so distance (already computed
/// for the delivery charge) plus time-of-day is the only signal available.
/// [distanceKm] is `null` when the address has no coordinates yet, same
/// condition that falls back to the flat delivery-charge placeholder.
DeliveryEta estimateDeliveryEta({
  required double? distanceKm,
  required DateTime now,
}) {
  if (distanceKm == null) return DeliveryEta.unknown;
  if (distanceKm <= AppConstants.kSameDayRadiusKm &&
      now.hour < AppConstants.kSameDayCutoffHour) {
    return DeliveryEta.today;
  }
  if (distanceKm <= AppConstants.kNextDayRadiusKm) return DeliveryEta.tomorrow;
  return DeliveryEta.fewDays;
}
