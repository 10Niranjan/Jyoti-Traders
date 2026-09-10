import 'package:firebase_core/firebase_core.dart';

/// Detects whether [app] is still on the generated placeholder credentials
/// (`firebase_options.dart` before `flutterfire configure` has been run).
///
/// Every repository that talks to Firestore checks this once at construction
/// time to decide between real Firestore calls and a Hive-backed simulation
/// mode — this keeps the app fully runnable/testable before a real Firebase
/// project is wired up.
bool isFirebasePlaceholder(FirebaseApp app) {
  return app.options.projectId == 'jyoti-traders-placeholder' ||
      app.options.projectId == 'jyoti-traders-demo' ||
      app.options.apiKey.contains('YOUR-') ||
      app.options.apiKey.contains('DummyKey');
}

