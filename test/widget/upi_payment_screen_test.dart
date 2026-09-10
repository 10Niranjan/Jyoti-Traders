import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/data/models/user_model.dart';
import 'package:traders_retailer/data/repositories/auth_repository_provider.dart';
import 'package:traders_retailer/data/repositories/repository_providers.dart';
import 'package:traders_retailer/domain/entities/address_entity.dart';
import 'package:traders_retailer/domain/entities/order_entity.dart';
import 'package:traders_retailer/domain/entities/order_item_entity.dart';
import 'package:traders_retailer/domain/repositories/order_repository.dart';
import 'package:traders_retailer/domain/value_objects/money.dart';
import 'package:traders_retailer/features/checkout/screens/upi_payment_screen.dart';
import 'package:traders_retailer/l10n/app_localizations.dart';

import '../helpers/fake_auth_repository.dart';

class FakeOrderRepository implements OrderRepository {
  final List<OrderEntity> orders;
  FakeOrderRepository(this.orders);

  @override
  Stream<List<OrderEntity>> watchAllOrders() => Stream.value(orders);

  @override
  Future<void> placeOrder(OrderEntity order) async {}

  @override
  Stream<List<OrderEntity>> watchOrderHistory(String userId) =>
      Stream.value(orders);

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {}

  @override
  Future<void> recordPaymentClaim(
    String orderId, {
    String? screenshotUrl,
  }) async {}

  @override
  Future<void> updatePaymentStatus(
    String orderId,
    PaymentStatus status,
  ) async {}
}

final _retailer = UserModel(
  uid: 'u1',
  name: 'Ramesh',
  email: 'ramesh@test.com',
  phone: '9876543210',
  role: UserRole.customer,
  status: UserStatus.approved,
  businessName: 'Ramesh Kirana Store',
  createdAt: DateTime(2026, 1, 1),
);

final _order = OrderEntity(
  id: 'order_upi_1',
  userId: 'u1',
  shopName: 'Ramesh Kirana Store',
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
  paymentStatus: PaymentStatus.pending,
  orderStatus: OrderStatus.pending,
  deliveryAddress: const AddressEntity(
    street: 'St',
    city: 'City',
    pincode: '123456',
  ),
  createdAt: DateTime(2026, 7, 20),
);

Widget _wrap(FakeOrderRepository repo, {String orderId = 'order_upi_1'}) =>
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(FakeAuthRepository(_retailer)),
        orderRepositoryProvider.overrideWithValue(repo),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: UpiPaymentScreen(orderId: orderId),
      ),
    );

void main() {
  testWidgets('shows the amount due and the UPI id', (tester) async {
    await tester.pumpWidget(_wrap(FakeOrderRepository([_order])));
    await tester.pumpAndSettle();

    expect(find.text('Pay ₹3,050'), findsOneWidget);
    expect(find.text('jyotitraders@upi'), findsOneWidget);
    expect(find.text('I Have Paid'), findsOneWidget);
  });

  testWidgets('tapping the UPI id copies it and confirms via snackbar', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(FakeOrderRepository([_order])));
    await tester.pumpAndSettle();

    await tester.tap(find.text('jyotitraders@upi'));
    await tester.pumpAndSettle();

    expect(find.text('UPI ID copied.'), findsOneWidget);
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
}
