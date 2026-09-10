import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../firebase_options.dart';
import '../utils/app_logger.dart';

/// Thin wrapper around `firebase_messaging`. Every entry point is wrapped in
/// its own try/catch and degrades to a no-op (null token / empty stream)
/// rather than throwing — mirrors every other Firebase-touching class in
/// this app (see `isFirebasePlaceholder`), except FCM has no meaningful
/// "simulation mode" substitute, so this is the defensive fallback for
/// unconfigured credentials, an unsupported platform (e.g. desktop), or a
/// test environment with no platform channel registered.
class FcmService {
  /// Requests notification permission and returns this device's current
  /// FCM token, or `null` if permission was denied or messaging is
  /// unavailable.
  Future<String?> requestPermissionAndGetToken() async {
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(alert: true, badge: true, sound: true);
      return await messaging.getToken();
    } catch (e) {
      logWarning('FcmService: permission/token request unavailable, skipping', e);
      return null;
    }
  }

  /// Fires whenever the device's FCM token rotates — the token must be
  /// re-saved to the user's profile each time.
  Stream<String> get onTokenRefresh {
    try {
      return FirebaseMessaging.instance.onTokenRefresh;
    } catch (e) {
      logWarning('FcmService: onTokenRefresh unavailable, skipping', e);
      return const Stream.empty();
    }
  }

  /// Messages received while the app is in the foreground. Background/
  /// terminated-state messages are handled by [firebaseMessagingBackgroundHandler]
  /// and rendered natively by the OS from the message's `notification` payload.
  Stream<RemoteMessage> get onForegroundMessage {
    try {
      return FirebaseMessaging.onMessage;
    } catch (e) {
      logWarning('FcmService: onMessage unavailable, skipping', e);
      return const Stream.empty();
    }
  }
}

/// Background/terminated-app message handler. Must be a top-level function
/// (Firebase launches it in a separate isolate) and re-initializes Firebase
/// itself, since that isolate doesn't share the main isolate's state.
///
/// Deliberately does no work beyond that: the OS already renders the
/// notification from the message's `notification` payload with zero app
/// code required, and this isolate can't safely touch the main isolate's
/// already-open Hive boxes to add it to notification history.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    logWarning('firebaseMessagingBackgroundHandler: Firebase init failed', e);
  }
}
