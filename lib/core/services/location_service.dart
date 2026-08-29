import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../utils/app_logger.dart';

/// Thin wrapper around `geolocator`. Every step (service-enabled check,
/// permission check/request, position fetch) is wrapped in a single
/// try/catch and returns `null` on any failure — denied permission,
/// disabled location services, or an unsupported platform — so callers
/// always have a graceful "couldn't get it" path instead of a thrown
/// exception, matching every other plugin-backed service in this app
/// (`FcmService`, `ImageUploadService`).
class LocationService {
  Future<Position?> getCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
    } catch (e) {
      logWarning('LocationService: unable to get current position, skipping', e);
      return null;
    }
  }
}

final locationServiceProvider = Provider<LocationService>((ref) => LocationService());
