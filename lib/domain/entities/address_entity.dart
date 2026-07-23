import 'package:equatable/equatable.dart';

/// A retailer's registered delivery address. [latitude]/[longitude] are
/// optional — only present once the retailer has used "current location"
/// while editing their address (Phase 5) — and drive real per-km delivery
/// charge calculation when available.
class AddressEntity extends Equatable {
  final String street;
  final String city;
  final String pincode;
  final double? latitude;
  final double? longitude;

  const AddressEntity({
    required this.street,
    required this.city,
    required this.pincode,
    this.latitude,
    this.longitude,
  });

  bool get hasCoordinates => latitude != null && longitude != null;

  @override
  List<Object?> get props => [street, city, pincode, latitude, longitude];
}
