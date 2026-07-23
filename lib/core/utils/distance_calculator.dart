import 'dart:math';

/// Great-circle (Haversine) distance between two lat/lng points, in
/// kilometers. Pure Dart — no plugin dependency — so it's safe to use from
/// the domain layer's delivery-charge use case, which must stay
/// Flutter/plugin-free. Actual GPS capture is a separate concern, handled
/// by `LocationService` (core/services), which does depend on `geolocator`.
double calculateDistanceKm(double lat1, double lng1, double lat2, double lng2) {
  const earthRadiusKm = 6371.0;
  final dLat = _degToRad(lat2 - lat1);
  final dLng = _degToRad(lng2 - lng1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_degToRad(lat1)) * cos(_degToRad(lat2)) * sin(dLng / 2) * sin(dLng / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadiusKm * c;
}

double _degToRad(double deg) => deg * (pi / 180);
