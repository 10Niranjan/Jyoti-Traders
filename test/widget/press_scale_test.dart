import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/shared/widgets/press_scale.dart';

void main() {
  testWidgets('tapping calls onTap and the scale returns to 1.0 afterwards', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PressScale(
            onTap: () => tapped = true,
            child: const SizedBox(
              width: 100,
              height: 40,
              child: Text('Tap me'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(PressScale));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
    final scale = tester.widget<AnimatedScale>(find.byType(AnimatedScale));
    expect(scale.scale, 1.0);
  });

  testWidgets('scales down while pressed, before release', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PressScale(
            onTap: () {},
            child: const SizedBox(
              width: 100,
              height: 40,
              child: Text('Tap me'),
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(PressScale)),
    );
    await tester.pump(const Duration(milliseconds: 50));

    final scale = tester.widget<AnimatedScale>(find.byType(AnimatedScale));
    expect(scale.scale, lessThan(1.0));

    await gesture.up();
    await tester.pumpAndSettle();
  });
}
