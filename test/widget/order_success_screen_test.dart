import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/features/checkout/screens/order_success_screen.dart';
import 'package:traders_retailer/l10n/app_localizations.dart';
import 'package:traders_retailer/shared/widgets/animated_success_check.dart';

Widget _app(Widget home, {bool disableAnimations = false}) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: disableAnimations),
    child: child!,
  ),
  home: home,
);

void main() {
  testWidgets('success check plays once, then stops animating', (tester) async {
    await tester.pumpWidget(_app(const Scaffold(body: AnimatedSuccessCheck())));

    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.hasRunningAnimations, isTrue);

    // A looping controller would never settle here and pumpAndSettle would
    // time out — that is exactly the regression this guards.
    await tester.pumpAndSettle();
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets(
    'success check skips straight to the end when animations are off',
    (tester) async {
      await tester.pumpWidget(
        _app(
          const Scaffold(body: AnimatedSuccessCheck()),
          disableAnimations: true,
        ),
      );
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);
    },
  );

  testWidgets(
    'order success screen shows the animation, title and order number',
    (tester) async {
      await tester.pumpWidget(
        _app(const OrderSuccessScreen(orderId: 'abcdef123456')),
      );
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(tester.element(find.byType(Scaffold)))!;
      expect(find.byType(AnimatedSuccessCheck), findsOneWidget);
      expect(find.text(l10n.orderSuccessTitle), findsOneWidget);
      expect(find.text(l10n.orderSuccessViewOrder), findsOneWidget);
    },
  );
}
