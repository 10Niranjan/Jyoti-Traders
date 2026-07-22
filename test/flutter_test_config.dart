import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

/// Runs once before every test in this directory tree.
///
/// By default, `tester.tap()` on a widget that isn't actually hit-testable —
/// most often because it sits below the fold of the 800x600 test surface —
/// only prints a warning and then does nothing. The test carries on against
/// a UI it never actually interacted with, which quietly turns "the button
/// didn't work" into a passing test. Making it fatal means a missed tap
/// fails loudly instead. Use `useTallTestViewport()` from
/// `helpers/test_viewport.dart` for screens that genuinely need more room.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  WidgetController.hitTestWarningShouldBeFatal = true;
  await testMain();
}
