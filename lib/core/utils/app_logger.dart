import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Routes a non-fatal warning to Crashlytics' log (visible in its console
/// alongside real crashes) in release builds, since `debugPrint` alone is
/// silently discarded once the app ships. In debug it just prints, same as
/// the `debugPrint` calls this replaces.
void logWarning(String message, [Object? error]) {
  final full = error == null ? message : '$message: $error';
  if (kReleaseMode) {
    try {
      FirebaseCrashlytics.instance.log(full);
    } catch (_) {
      // Firebase not initialized yet (e.g. logged before Firebase.initializeApp
      // completes) — dropping the log line is fine, this is best-effort.
    }
  } else {
    debugPrint(full);
  }
}
