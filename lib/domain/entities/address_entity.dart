import 'package:equatable/equatable.dart';

/// A retailer's registered delivery address. [latitude]/[longitude] are
/// optional — only present once the retailer has used "current location"
/// while editing their address — and drive real per-km delivery charge
/// calculation when available. They are never shown to the retailer as raw
/// numbers; [formattedAddress] is the human-readable line resolved from
/// them (via reverse geocoding) and is what the UI displays.
class AddressEntity extends Equatable {
  final String street;
  final String city;
  final String pincode;
  final double? latitude;
  final double? longitude;
  final String? formattedAddress;

  /// Only set for an entry saved into [UserEntity.savedAddresses] — a
  /// checkout-frozen or single "current" address (the common case, e.g.
  /// [OrderEntity.deliveryAddress]) never needs one.
  final String? id;

  /// Retailer-chosen name for a saved address, e.g. "Shop", "Warehouse".
  final String? label;

  const AddressEntity({
    required this.street,
    required this.city,
    required this.pincode,
    this.latitude,
    this.longitude,
    this.formattedAddress,
    this.id,
    this.label,
  });

  bool get hasCoordinates => latitude != null && longitude != null;

  AddressEntity copyWith({
    String? street,
    String? city,
    String? pincode,
    double? latitude,
    double? longitude,
    String? formattedAddress,
    String? id,
    String? label,
  }) {
    return AddressEntity(
      street: street ?? this.street,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      formattedAddress: formattedAddress ?? this.formattedAddress,
      id: id ?? this.id,
      label: label ?? this.label,
    );
  }

  @override
  List<Object?> get props => [
    street,
    city,
    pincode,
    latitude,
    longitude,
    formattedAddress,
    id,
    label,
  ];
}
