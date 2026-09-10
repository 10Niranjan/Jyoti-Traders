import '../../../core/constants/app_constants.dart';
import '../../../core/utils/distance_calculator.dart';
import '../../entities/address_entity.dart';
import '../../entities/delivery_config_entity.dart';
import '../../value_objects/money.dart';

/// Straight-line (Haversine) distance from the warehouse to the retailer,
/// times the admin-set per-km rate. Returns `null` when the address has no
/// captured coordinates — the caller falls back to a flat placeholder
/// rather than blocking checkout on a delivery charge it can't compute.
class CalculateDeliveryChargeUseCase {
  Money? call({
    required DeliveryConfigEntity config,
    required AddressEntity address,
  }) {
    if (!address.hasCoordinates) return null;
    final distanceKm = calculateDistanceKm(
      config.warehouseLat,
      config.warehouseLng,
      address.latitude!,
      address.longitude!,
    );
    return Money(distanceKm * config.perKmRate);
  }
}

/// Real per-km charge when [address] has coordinates and [config] has
/// loaded; the flat placeholder otherwise (no address yet, or the config
/// stream hasn't emitted). Single source of truth for this fallback so Cart
/// and Checkout can never show two different totals for the same order —
/// they both call this instead of each keeping their own copy of the logic.
Money resolveDeliveryCharge({
  required AddressEntity? address,
  required DeliveryConfigEntity? config,
}) {
  if (address == null || config == null) {
    return Money(AppConstants.kStubDeliveryCharge);
  }
  return CalculateDeliveryChargeUseCase()(config: config, address: address) ??
      Money(AppConstants.kStubDeliveryCharge);
}
