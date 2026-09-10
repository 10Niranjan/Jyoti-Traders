import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/data/repositories/repository_providers.dart';
import 'package:traders_retailer/domain/entities/address_entity.dart';
import 'package:traders_retailer/domain/entities/order_entity.dart';
import 'package:traders_retailer/domain/entities/order_item_entity.dart';
import 'package:traders_retailer/domain/repositories/order_repository.dart';
import 'package:traders_retailer/domain/value_objects/money.dart';
import 'package:traders_retailer/features/admin/screens/order_management_screen.dart';
import 'package:traders_retailer/l10n/app_localizations.dart';

import '../helpers/test_viewport.dart';

class FakeOrderRepository implements OrderRepository {
  final List<OrderEntity> orders;
  final List<(String, OrderStatus)> statusUpdates = [];
  final List<String> paymentStatusUpdates = [];
  FakeOrderRepository(this.orders);

  @override
  Stream<List<OrderEntity>> watchAllOrders() => Stream.value(orders);

  @override
  Future<void> placeOrder(OrderEntity order) async {}

  @override
  Stream<List<OrderEntity>> watchOrderHistory(String userId) =>
      Stream.value(orders);

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    statusUpdates.add((orderId, status));
  }

  @override
  Future<void> recordPaymentClaim(
    String orderId, {
    String? screenshotUrl,
  }) async {}

  @override
  Future<void> updatePaymentStatus(String orderId, PaymentStatus status) async {
    paymentStatusUpdates.add(orderId);
  }
}

final _order = OrderEntity(
  id: 'o1',
  userId: 'u1',
  shopName: 'Basmati Traders',
  items: [
    OrderItemEntity(
      productId: 'p1',
      name: 'Basmati Rice',
      qty: 2,
      unitPrice: Money(1500),
    ),
  ],
  subtotal: Money(3000),
  deliveryCharge: Money(50),
  paymentMethod: PaymentMethod.cod,
  paymentStatus: PaymentStatus.pending,
  orderStatus: OrderStatus.pending,
  deliveryAddress: const AddressEntity(
    street: 'St',
    city: 'City',
    pincode: '123456',
  ),
  createdAt: DateTime(2026, 7, 20),
);

Widget _wrap(FakeOrderRepository repo, {String orderId = 'o1'}) =>
    ProviderScope(
      overrides: [orderRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: OrderManagementScreen(orderId: orderId),
      ),
    );

void main() {
  useTallTestViewport();

  testWidgets('renders the order breakdown with the shop name', (tester) async {
    await tester.pumpWidget(_wrap(FakeOrderRepository([_order])));
    await tester.pumpAndSettle();

    expect(find.text('Basmati Traders'), findsOneWidget);
    expect(find.textContaining('Basmati Rice'), findsOneWidget);
    expect(find.text('₹3,050'), findsOneWidget); // grand total
  });

  testWidgets('shows a not-found state for an unknown order id', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(FakeOrderRepository([_order]), orderId: 'missing'),
    );
    await tester.pumpAndSettle();

    expect(find.text('This order could not be found.'), findsOneWidget);
  });

  testWidgets(
    'changing the status dropdown calls the repository and confirms via snackbar',
    (tester) async {
      final repo = FakeOrderRepository([_order]);
      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<OrderStatus>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirmed').last);
      await tester.pumpAndSettle();

      expect(repo.statusUpdates, [('o1', OrderStatus.confirmed)]);
      expect(find.text('Status updated to Confirmed.'), findsOneWidget);
    },
  );

  testWidgets('COD orders also show payment status and a Mark as Paid button', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(FakeOrderRepository([_order])));
    await tester.pumpAndSettle();

    // COD is "cash due on delivery" — pending until the admin confirms it
    // was actually collected, same as a UPI claim needing confirmation.
    expect(find.text('Mark as Paid'), findsOneWidget);
    expect(find.text('Awaiting payment'), findsOneWidget);
  });

  testWidgets(
    'UPI orders show payment status and a working Mark as Paid button',
    (tester) async {
      final upiOrder = OrderEntity(
        id: 'o2',
        userId: 'u1',
        shopName: 'Basmati Traders',
        items: [
          OrderItemEntity(
            productId: 'p1',
            name: 'Basmati Rice',
            qty: 2,
            unitPrice: Money(1500),
          ),
        ],
        subtotal: Money(3000),
        deliveryCharge: Money(50),
        paymentMethod: PaymentMethod.upi,
        paymentStatus: PaymentStatus.paymentClaimed,
        orderStatus: OrderStatus.pending,
        deliveryAddress: const AddressEntity(
          street: 'St',
          city: 'City',
          pincode: '123456',
        ),
        createdAt: DateTime(2026, 7, 20),
      );
      final repo = FakeOrderRepository([upiOrder]);
      await tester.pumpWidget(_wrap(repo, orderId: 'o2'));
      await tester.pumpAndSettle();

      expect(
        find.text('Payment claimed — awaiting confirmation'),
        findsOneWidget,
      );
      expect(find.text('Mark as Paid'), findsOneWidget);

      await tester.tap(find.text('Mark as Paid'));
      await tester.pumpAndSettle();

      expect(repo.paymentStatusUpdates, ['o2']);
      expect(find.text('Payment confirmed.'), findsOneWidget);
    },
  );

  testWidgets('already-paid UPI orders hide the Mark as Paid button', (
    tester,
  ) async {
    final paidOrder = OrderEntity(
      id: 'o3',
      userId: 'u1',
      shopName: 'Basmati Traders',
      items: [
        OrderItemEntity(
          productId: 'p1',
          name: 'Basmati Rice',
          qty: 2,
          unitPrice: Money(1500),
        ),
      ],
      subtotal: Money(3000),
      deliveryCharge: Money(50),
      paymentMethod: PaymentMethod.upi,
      paymentStatus: PaymentStatus.paid,
      orderStatus: OrderStatus.pending,
      deliveryAddress: const AddressEntity(
        street: 'St',
        city: 'City',
        pincode: '123456',
      ),
      createdAt: DateTime(2026, 7, 20),
    );
    await tester.pumpWidget(
      _wrap(FakeOrderRepository([paidOrder]), orderId: 'o3'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Paid'), findsOneWidget);
    expect(find.text('Mark as Paid'), findsNothing);
  });
}
