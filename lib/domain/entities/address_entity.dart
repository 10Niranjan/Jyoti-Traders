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

  const AddressEntity({
    required this.street,
    required this.city,
    required this.pincode,
    this.latitude,
    this.longitude,
    this.formattedAddress,
  });

  bool get hasCoordinates => latitude != null && longitude != null;

  AddressEntity copyWith({
    String? street,
    String? city,
    String? pincode,
    double? latitude,
    double? longitude,
    String? formattedAddress,
  }) {
    return AddressEntity(
      street: street ?? this.street,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      formattedAddress: formattedAddress ?? this.formattedAddress,
    );
  }

  @override
  List<Object?> get props => [street, city, pincode, latitude, longitude, formattedAddress];
}
