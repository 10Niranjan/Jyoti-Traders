import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import '../utils/app_logger.dart';

/// Resolved street/city/pincode plus a human-readable line, derived from a
/// GPS coordinate. Distinct from [AddressEntity] — this is what the device's
/// reverse-geocoder gave us, before the retailer has had a chance to review
/// or edit it.
class ResolvedPlacemark {
  final String? street;
  final String? city;
  final String? pincode;
  final String formattedAddress;

  const ResolvedPlacemark({
    required this.street,
    required this.city,
    required this.pincode,
    required this.formattedAddress,
  });
}

/// Thin wrapper around `geocoding`'s on-device reverse-geocoder. Mirrors
/// `LocationService`: every failure (no network, no geocoder on this
/// platform, empty result) is swallowed and surfaced as `null` so callers
/// always have a graceful "couldn't resolve it" path instead of a thrown
/// exception.
class GeocodingService {
  Future<ResolvedPlacemark?> reverseGeocode({required double latitude, required double longitude}) async {
    try {
      final placemarks = await geocoding.placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) return null;
      final place = placemarks.first;

      final street = [place.subThoroughfare, place.thoroughfare, place.subLocality]
          .where((p) => p != null && p.trim().isNotEmpty)
          .join(', ');
      final city = place.locality?.trim().isNotEmpty == true ? place.locality! : place.subAdministrativeArea ?? '';
      final pincode = place.postalCode ?? '';

      final formatted = [street, city, if (pincode.isNotEmpty) pincode]
          .where((p) => p.trim().isNotEmpty)
          .join(', ');
      if (formatted.trim().isEmpty) return null;

      return ResolvedPlacemark(
        street: street.isEmpty ? null : street,
        city: city.isEmpty ? null : city,
        pincode: pincode.isEmpty ? null : pincode,
        formattedAddress: formatted,
      );
    } catch (e) {
      logWarning('GeocodingService: unable to resolve address, skipping', e);
      return null;
    }
  }
}

final geocodingServiceProvider = Provider<GeocodingService>((ref) => GeocodingService());
