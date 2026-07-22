import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/data/repositories/repository_providers.dart';
import 'package:traders_retailer/domain/entities/address_entity.dart';
import 'package:traders_retailer/domain/entities/order_entity.dart';
import 'package:traders_retailer/domain/entities/order_item_entity.dart';
import 'package:traders_retailer/domain/repositories/order_repository.dart';
import 'package:traders_retailer/domain/value_objects/money.dart';
import 'package:traders_retailer/features/admin/screens/all_orders_screen.dart';

class FakeOrderRepository implements OrderRepository {
  final List<OrderEntity> orders;
  FakeOrderRepository(this.orders);

  @override
  Stream<List<OrderEntity>> watchAllOrders() => Stream.value(orders);

  @override
  Future<void> placeOrder(OrderEntity order) async {}

  @override
  Stream<List<OrderEntity>> watchOrderHistory(String userId) => Stream.value(orders);

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {}
}

OrderEntity _order({
  required String id,
  required String shopName,
  OrderStatus status = OrderStatus.pending,
}) =>
    OrderEntity(
      id: id,
      userId: 'u1',
      shopName: shopName,
      items: [OrderItemEntity(productId: 'p1', name: 'Basmati Rice', qty: 2, unitPrice: Money(1500))],
      subtotal: Money(3000),
      deliveryCharge: Money(50),
      paymentMethod: PaymentMethod.cod,
      paymentStatus: PaymentStatus.pending,
      orderStatus: status,
      deliveryAddress: const AddressEntity(street: 'St', city: 'City', pincode: '123456'),
      createdAt: DateTime(2026, 7, 20),
    );

Widget _wrap(FakeOrderRepository repo) => ProviderScope(
      overrides: [orderRepositoryProvider.overrideWithValue(repo)],
      child: const MaterialApp(home: AllOrdersScreen()),
    );

void main() {
  testWidgets('shows an empty state when there are no orders', (tester) async {
    await tester.pumpWidget(_wrap(FakeOrderRepository([])));
    await tester.pumpAndSettle();

    expect(find.text('No orders yet'), findsOneWidget);
  });

  testWidgets('lists every order with shop name and status by default', (tester) async {
    await tester.pumpWidget(_wrap(FakeOrderRepository([
      _order(id: 'o1', shopName: 'Shop A', status: OrderStatus.pending),
      _order(id: 'o2', shopName: 'Shop B', status: OrderStatus.delivered),
    ])));
    await tester.pumpAndSettle();

    expect(find.text('Shop A'), findsOneWidget);
    expect(find.text('Shop B'), findsOneWidget);
  });

  testWidgets('filtering by status hides orders in other statuses', (tester) async {
    await tester.pumpWidget(_wrap(FakeOrderRepository([
      _order(id: 'o1', shopName: 'Shop A', status: OrderStatus.pending),
      _order(id: 'o2', shopName: 'Shop B', status: OrderStatus.delivered),
    ])));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilterChip, 'Delivered'));
    await tester.pumpAndSettle();

    expect(find.text('Shop A'), findsNothing);
    expect(find.text('Shop B'), findsOneWidget);
  });

  testWidgets('shows a status-specific empty message when a filter matches nothing', (tester) async {
    await tester.pumpWidget(_wrap(FakeOrderRepository([
      _order(id: 'o1', shopName: 'Shop A', status: OrderStatus.pending),
    ])));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilterChip, 'Delivered'));
    await tester.pumpAndSettle();

    expect(find.text('No delivered orders'), findsOneWidget);
  });
}
