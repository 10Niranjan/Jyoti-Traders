import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/domain/entities/order_entity.dart';
import 'package:traders_retailer/shared/widgets/order_tracking_stepper.dart';

Widget _wrap(OrderStatus status) => MaterialApp(
  home: Scaffold(body: OrderTrackingStepper(status: status)),
);

void main() {
  testWidgets('shows all four steps for a pending order', (tester) async {
    await tester.pumpWidget(_wrap(OrderStatus.pending));

    expect(find.text('Order Placed'), findsOneWidget);
    expect(find.text('Confirmed'), findsOneWidget);
    expect(find.text('Out for Delivery'), findsOneWidget);
    expect(find.text('Delivered'), findsOneWidget);
    expect(find.text('Order Cancelled'), findsNothing);
  });

  testWidgets(
    'shows a single Order Cancelled row for a cancelled order, not the stepper',
    (tester) async {
      await tester.pumpWidget(_wrap(OrderStatus.cancelled));

      expect(find.text('Order Cancelled'), findsOneWidget);
      expect(find.text('Order Placed'), findsNothing);
      expect(find.text('Delivered'), findsNothing);
    },
  );

  testWidgets('renders without overflow for every real status', (tester) async {
    for (final status in OrderStatus.values) {
      await tester.pumpWidget(_wrap(status));
      expect(tester.takeException(), isNull);
    }
  });
}
