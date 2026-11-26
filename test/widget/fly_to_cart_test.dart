import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/shared/widgets/fly_to_cart.dart';

void main() {
  group('flightPosition', () {
    const from = Offset(40, 100);
    const to = Offset(200, 700);

    test('starts at the tap and ends on the cart bar', () {
      expect(flightPosition(from, to, 0), from);
      expect(flightPosition(from, to, 1), to);
    });

    test('bows upward mid-flight instead of sliding in a straight line', () {
      final mid = flightPosition(from, to, 0.5);
      final straightLineY = (from.dy + to.dy) / 2;
      expect(mid.dy, lessThan(straightLineY));
    });
  });

  group('flyToCart', () {
    const barKey = ValueKey('bar');

    Widget host({List<Widget> bars = const []}) => MaterialApp(
      home: Scaffold(body: Stack(children: bars)),
    );

    Widget bar(Key key, {double bottom = 20}) => Positioned(
      left: 20,
      right: 20,
      bottom: bottom,
      height: 50,
      child: CartFlightTarget(
        child: ColoredBox(key: key, color: Colors.black),
      ),
    );

    testWidgets('a flight appears, then removes itself when it lands', (
      tester,
    ) async {
      await tester.pumpWidget(host(bars: [bar(barKey)]));
      final overlay = tester.state<OverlayState>(find.byType(Overlay).first);

      flyToCart(
        overlay,
        from: const Rect.fromLTWH(10, 10, 40, 30),
        imageUrl: '',
      );
      await tester.pump();
      expect(find.byKey(const ValueKey('cart-flyer')), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('cart-flyer')), findsNothing);
    });

    testWidgets('lands on the cart bar', (tester) async {
      await tester.pumpWidget(host(bars: [bar(barKey)]));
      final overlay = tester.state<OverlayState>(find.byType(Overlay).first);

      flyToCart(
        overlay,
        from: const Rect.fromLTWH(10, 10, 40, 30),
        imageUrl: '',
      );
      await tester.pump();
      await tester.pump(
        const Duration(milliseconds: 645),
      ); // just before the end

      final flyer = tester.getCenter(find.byKey(const ValueKey('cart-flyer')));
      final target = tester.getCenter(find.byKey(barKey));
      expect((flyer - target).distance, lessThan(6));
      await tester.pumpAndSettle();
    });

    testWidgets('aims at the newest of several cart bars', (tester) async {
      // Shell bar (always mounted) plus one pushed on top of it later.
      const topKey = ValueKey('top-bar');
      await tester.pumpWidget(host(bars: [bar(barKey, bottom: 120)]));
      await tester.pumpWidget(
        host(bars: [bar(barKey, bottom: 120), bar(topKey, bottom: 20)]),
      );
      final overlay = tester.state<OverlayState>(find.byType(Overlay).first);

      flyToCart(
        overlay,
        from: const Rect.fromLTWH(10, 10, 40, 30),
        imageUrl: '',
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 645));

      final flyer = tester.getCenter(find.byKey(const ValueKey('cart-flyer')));
      expect(
        (flyer - tester.getCenter(find.byKey(topKey))).distance,
        lessThan(6),
      );
      await tester.pumpAndSettle();
    });

    testWidgets(
      'with no cart bar mounted it still lands at the screen bottom',
      (tester) async {
        await tester.pumpWidget(host());
        final overlay = tester.state<OverlayState>(find.byType(Overlay).first);

        flyToCart(
          overlay,
          from: const Rect.fromLTWH(10, 10, 40, 30),
          imageUrl: '',
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 645));

        final flyer = tester.getCenter(
          find.byKey(const ValueKey('cart-flyer')),
        );
        final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
        expect(flyer.dx, closeTo(screen.width / 2, 6));
        expect(flyer.dy, greaterThan(screen.height - 100));
        await tester.pumpAndSettle();
      },
    );
  });
}
