import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/domain/entities/address_entity.dart';
import 'package:traders_retailer/domain/entities/order_entity.dart';
import 'package:traders_retailer/domain/entities/order_item_entity.dart';
import 'package:traders_retailer/domain/value_objects/money.dart';
import 'package:traders_retailer/l10n/app_localizations.dart';
import 'package:traders_retailer/shared/widgets/share_invoice_button.dart';

OrderEntity _order(OrderStatus status) => OrderEntity(
  id: 'abcdef12-3456-7890-abcd-ef1234567890',
  userId: 'u1',
  shopName: 'Ramesh Kirana Store',
  items: [
    OrderItemEntity(
      productId: 'p1',
      name: 'Rice',
      qty: 2,
      unitPrice: Money(1500),
    ),
  ],
  subtotal: Money(3000),
  deliveryCharge: Money(50),
  paymentMethod: PaymentMethod.cod,
  paymentStatus: PaymentStatus.pending,
  orderStatus: status,
  deliveryAddress: const AddressEntity(
    street: 'St',
    city: 'City',
    pincode: '123456',
  ),
  createdAt: DateTime(2026, 9, 19),
);

Widget _wrap(OrderEntity order) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    appBar: AppBar(actions: [ShareInvoiceButton(order: order)]),
  ),
);

void main() {
  testWidgets('is offered for a live order', (tester) async {
    await tester.pumpWidget(_wrap(_order(OrderStatus.confirmed)));
    expect(find.byTooltip('Share invoice (PDF)'), findsOneWidget);
  });

  testWidgets('is hidden for a cancelled order — nothing was sold', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(_order(OrderStatus.cancelled)));
    expect(find.byTooltip('Share invoice (PDF)'), findsNothing);
  });

  testWidgets(
    'building and sharing finishes cleanly and re-enables the button',
    (tester) async {
      await tester.pumpWidget(_wrap(_order(OrderStatus.confirmed)));

      await tester.tap(find.byTooltip('Share invoice (PDF)'));
      await tester.pump();
      // Font loading and PDF layout are real async work, which the fake test
      // clock doesn't advance — give them real time to finish.
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(seconds: 2)),
      );
      await tester.pumpAndSettle();

      // No share sheet exists in a widget test; that call is swallowed and
      // logged, so the only visible outcomes are: no error, no failure toast,
      // and the button usable again.
      expect(tester.takeException(), isNull);
      expect(
        find.text("Couldn't create the invoice. Please try again."),
        findsNothing,
      );
      expect(
        tester.widget<IconButton>(find.byType(IconButton)).onPressed,
        isNotNull,
      );
    },
  );
}
