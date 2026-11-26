import 'package:firebase_core/firebase_core.dart';

/// Detects whether [app] is still on the generated placeholder credentials
/// (`firebase_options.dart` before `flutterfire configure` has been run).
///
/// Every repository that talks to Firestore checks this once at construction
/// time to decide between real Firestore calls and a Hive-backed simulation
/// mode — this keeps the app fully runnable/testable before a real Firebase
/// project is wired up.
bool isFirebasePlaceholder(FirebaseApp app) {
  // `--dart-define=DEMO_MODE=true` forces the offline demo data on a build
  // that has real credentials — for showing the app without touching live data.
  if (const bool.fromEnvironment('DEMO_MODE')) return true;
  return app.options.projectId == 'jyoti-traders-placeholder' ||
      app.options.projectId == 'jyoti-traders-demo' ||
      app.options.apiKey.contains('YOUR-') ||
      app.options.apiKey.contains('DummyKey');
}
