import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Widens/heightens the test surface for the duration of each test in the
/// enclosing group, restoring it afterwards.
///
/// The default test surface is 800x600. Anything taller — long scrollable
/// forms in particular — renders its lower half outside the surface, where
/// taps do not hit-test. `flutter_test_config.dart` makes those missed taps
/// fatal rather than silent, and this is the fix for screens that legitimately
/// need the extra room.
///
/// Call inside a `main()` or `group()` body, before the `testWidgets` calls:
///
/// ```dart
/// void main() {
///   useTallTestViewport();
///
///   testWidgets('submits the form', (tester) async { ... });
/// }
/// ```
void useTallTestViewport({Size size = const Size(1000, 2400)}) {
  setUp(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher.views.first;
    view.physicalSize = size;
    view.devicePixelRatio = 1.0;
  });

  tearDown(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher.views.first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });
}
