import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/data/repositories/repository_providers.dart';
import 'package:traders_retailer/domain/entities/address_entity.dart';
import 'package:traders_retailer/domain/entities/order_entity.dart';
import 'package:traders_retailer/domain/entities/order_item_entity.dart';
import 'package:traders_retailer/domain/repositories/order_repository.dart';
import 'package:traders_retailer/domain/value_objects/money.dart';
import 'package:traders_retailer/features/admin/controllers/admin_dashboard_controller.dart';

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

  @override
  Future<void> recordPaymentClaim(String orderId, {String? screenshotUrl}) async {}

  @override
  Future<void> updatePaymentStatus(String orderId, PaymentStatus status) async {}
}

OrderEntity _order(
  String id,
  DateTime createdAt, {
  List<OrderItemEntity>? items,
  OrderStatus status = OrderStatus.pending,
  double subtotal = 3000,
  double deliveryCharge = 50,
}) =>
    OrderEntity(
      id: id,
      userId: 'u1',
      shopName: 'Shop u1',
      items: items ?? [OrderItemEntity(productId: 'p1', name: 'Item', qty: 1, unitPrice: Money(subtotal))],
      subtotal: Money(subtotal),
      deliveryCharge: Money(deliveryCharge),
      paymentMethod: PaymentMethod.cod,
      paymentStatus: PaymentStatus.pending,
      orderStatus: status,
      deliveryAddress: const AddressEntity(street: 'St', city: 'City', pincode: '123456'),
      createdAt: createdAt,
    );

void main() {
  group('todayRevenueProvider', () {
    test('sums grandTotal for today\'s orders only', () async {
      final now = DateTime.now();
      final container = ProviderContainer(overrides: [
        orderRepositoryProvider.overrideWithValue(FakeOrderRepository([
          _order('today1', now, subtotal: 3000, deliveryCharge: 50),
          _order('today2', now, subtotal: 2000, deliveryCharge: 0),
          _order('yesterday', now.subtract(const Duration(days: 1)), subtotal: 5000, deliveryCharge: 0),
        ])),
      ]);
      addTearDown(container.dispose);

      await container.read(allOrdersProvider.future);
      expect(container.read(todayRevenueProvider).value, 3050 + 2000);
    });

    test('excludes cancelled orders', () async {
      final now = DateTime.now();
      final container = ProviderContainer(overrides: [
        orderRepositoryProvider.overrideWithValue(FakeOrderRepository([
          _order('cancelled', now, subtotal: 9999, status: OrderStatus.cancelled),
          _order('valid', now, subtotal: 100, deliveryCharge: 0),
        ])),
      ]);
      addTearDown(container.dispose);

      await container.read(allOrdersProvider.future);
      expect(container.read(todayRevenueProvider).value, 100);
    });
  });

  group('topProductsProvider', () {
    test('ranks products by total revenue, highest first', () async {
      final now = DateTime.now();
      final container = ProviderContainer(overrides: [
        orderRepositoryProvider.overrideWithValue(FakeOrderRepository([
          _order(
            'o1',
            now,
            items: [
              OrderItemEntity(productId: 'p1', name: 'Rice', qty: 1, unitPrice: Money(100)),
              OrderItemEntity(productId: 'p2', name: 'Sugar', qty: 1, unitPrice: Money(500)),
            ],
          ),
          _order(
            'o2',
            now,
            items: [
              OrderItemEntity(productId: 'p1', name: 'Rice', qty: 1, unitPrice: Money(100)),
            ],
          ),
        ])),
      ]);
      addTearDown(container.dispose);

      await container.read(allOrdersProvider.future);
      final products = container.read(topProductsProvider).value!;
      expect(products.map((p) => p.name), ['Sugar', 'Rice']);
      expect(products.first.revenue, 500);
      expect(products.last.revenue, 200);
    });

    test('excludes cancelled orders from ranking', () async {
      final now = DateTime.now();
      final container = ProviderContainer(overrides: [
        orderRepositoryProvider.overrideWithValue(FakeOrderRepository([
          _order(
            'cancelled',
            now,
            status: OrderStatus.cancelled,
            items: [OrderItemEntity(productId: 'p1', name: 'Rice', qty: 1, unitPrice: Money(9999))],
          ),
        ])),
      ]);
      addTearDown(container.dispose);

      await container.read(allOrdersProvider.future);
      expect(container.read(topProductsProvider).value, isEmpty);
    });
  });
}
