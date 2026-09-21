import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/domain/entities/address_entity.dart';
import 'package:traders_retailer/domain/entities/order_entity.dart';
import 'package:traders_retailer/domain/entities/order_item_entity.dart';
import 'package:traders_retailer/domain/entities/product_entity.dart';
import 'package:traders_retailer/domain/entities/user_entity.dart';
import 'package:traders_retailer/domain/value_objects/money.dart';
import 'package:traders_retailer/core/utils/trend.dart';
import 'package:traders_retailer/features/admin/controllers/admin_dashboard_controller.dart';
import 'package:traders_retailer/features/admin/controllers/admin_product_controller.dart';

OrderEntity _order(
  String id,
  DateTime createdAt, {
  double subtotal = 3000,
  OrderStatus status = OrderStatus.pending,
  PaymentMethod method = PaymentMethod.cod,
  PaymentStatus payment = PaymentStatus.pending,
}) => OrderEntity(
  id: id,
  userId: 'u1',
  shopName: 'Shop',
  items: [
    OrderItemEntity(
      productId: 'p1',
      name: 'Item',
      qty: 1,
      unitPrice: Money(10),
    ),
  ],
  subtotal: Money(subtotal),
  deliveryCharge: Money(0),
  paymentMethod: method,
  paymentStatus: payment,
  orderStatus: status,
  deliveryAddress: const AddressEntity(
    street: 'St',
    city: 'City',
    pincode: '123456',
  ),
  createdAt: createdAt,
);

ProductEntity _product(String id, int stock, {bool isActive = true}) =>
    ProductEntity(
      id: id,
      name: 'P$id',
      categoryId: 'c1',
      imageUrl: '',
      price: Money(100),
      unit: ProductUnit.box,
      stock: stock,
      isActive: isActive,
    );

UserEntity _pendingUser(String uid) => UserEntity(
  uid: uid,
  fullName: 'Owner',
  shopName: 'Shop',
  email: '$uid@test.com',
  phone: '9876543210',
  role: UserRole.customer,
  status: UserStatus.pending,
  createdAt: DateTime(2026, 1, 1),
);

Future<void> _settle() async {
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

ProviderContainer _container({
  List<OrderEntity> orders = const [],
  List<ProductEntity> products = const [],
  List<UserEntity> pending = const [],
  bool productsNeverLoad = false,
}) {
  final c = ProviderContainer(
    overrides: [
      allOrdersProvider.overrideWith((ref) => Stream.value(orders)),
      allProductsProvider.overrideWith(
        (ref) => productsNeverLoad
            ? StreamController<List<ProductEntity>>().stream
            : Stream.value(products),
      ),
      pendingUsersProvider.overrideWith((ref) => Stream.value(pending)),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  group('trendPercent', () {
    test('is null when there is no baseline', () {
      expect(trendPercent(5, 0), isNull);
      expect(trendPercent(0, 0), isNull);
    });

    test('is the signed percentage change', () {
      expect(trendPercent(15, 10), 50);
      expect(trendPercent(5, 10), -50);
      expect(trendPercent(10, 10), 0);
    });
  });

  group('today vs the same window last week', () {
    test('compares order counts', () async {
      final now = DateTime.now();
      final lastWeek = now.subtract(const Duration(days: 7));
      final c = _container(
        orders: [
          _order('t1', now),
          _order('t2', now),
          _order('t3', now),
          _order('w1', lastWeek),
          _order('w2', lastWeek),
        ],
      );
      c.listen(todayOrdersTrendProvider, (_, _) {});
      await _settle();

      // 3 today so far vs 2 at this time last week.
      expect(c.read(todayOrdersTrendProvider).value, closeTo(50, 1e-9));
    });

    test(
      'ignores last week orders placed later in that day than it is now',
      () async {
        final now = DateTime.now();
        final lastWeek = now.subtract(const Duration(days: 7));
        final c = _container(
          orders: [
            _order('t1', now),
            _order('t2', now),
            _order('w1', lastWeek),
            // Later that same day last week — hadn't happened yet at this time
            // of day, so it must not deflate today's number.
            _order('w2', lastWeek.add(const Duration(hours: 2))),
          ],
        );
        c.listen(todayOrdersTrendProvider, (_, _) {});
        await _settle();

        expect(c.read(todayOrdersTrendProvider).value, closeTo(100, 1e-9));
      },
    );

    test('is null with nothing to compare against', () async {
      final c = _container(orders: [_order('t1', DateTime.now())]);
      c.listen(todayOrdersTrendProvider, (_, _) {});
      await _settle();

      expect(c.read(todayOrdersTrendProvider).value, isNull);
    });

    test('revenue trend skips cancelled orders', () async {
      final now = DateTime.now();
      final lastWeek = now.subtract(const Duration(days: 7));
      final c = _container(
        orders: [
          _order('t1', now, subtotal: 3000),
          _order('t2', now, subtotal: 9000, status: OrderStatus.cancelled),
          _order('w1', lastWeek, subtotal: 2000),
        ],
      );
      c.listen(todayRevenueTrendProvider, (_, _) {});
      await _settle();

      // 3000 (cancelled 9000 ignored) vs 2000.
      expect(c.read(todayRevenueTrendProvider).value, closeTo(50, 1e-9));
    });
  });

  group('attentionSummaryProvider', () {
    test('counts each thing waiting on the owner', () async {
      final now = DateTime.now();
      final c = _container(
        pending: [_pendingUser('a'), _pendingUser('b')],
        orders: [
          // UPI paid-claimed, not yet confirmed -> counted.
          _order(
            'u1',
            now,
            method: PaymentMethod.upi,
            payment: PaymentStatus.paymentClaimed,
            status: OrderStatus.confirmed,
          ),
          // Same, but cancelled -> not counted.
          _order(
            'u2',
            now,
            method: PaymentMethod.upi,
            payment: PaymentStatus.paymentClaimed,
            status: OrderStatus.cancelled,
          ),
          // Already marked paid -> not counted.
          _order(
            'u3',
            now,
            method: PaymentMethod.upi,
            payment: PaymentStatus.paid,
            status: OrderStatus.confirmed,
          ),
          // Pending for over the threshold -> stale.
          _order('s1', now.subtract(const Duration(minutes: 45))),
          // Pending but recent -> not stale.
          _order('s2', now.subtract(const Duration(minutes: 5))),
        ],
        products: [
          _product('low', 3),
          _product('empty', 0),
          _product('inactiveLow', 2, isActive: false), // hidden -> ignored
          _product('fine', 50),
        ],
      );
      c.listen(attentionSummaryProvider, (_, _) {});
      await _settle();

      final summary = c.read(attentionSummaryProvider)!;
      expect(summary.pendingApprovals, 2);
      expect(summary.unconfirmedPayments, 1);
      expect(summary.staleOrders, 1);
      expect(summary.lowStockProducts, 2);
      expect(summary.isClear, isFalse);
    });

    test('is clear when nothing is waiting', () async {
      final c = _container(
        orders: [_order('d1', DateTime.now(), status: OrderStatus.delivered)],
        products: [_product('fine', 50)],
      );
      c.listen(attentionSummaryProvider, (_, _) {});
      await _settle();

      expect(c.read(attentionSummaryProvider)!.isClear, isTrue);
    });

    test('is null until every source has loaded', () async {
      final c = _container(productsNeverLoad: true);
      c.listen(attentionSummaryProvider, (_, _) {});
      await _settle();

      expect(c.read(attentionSummaryProvider), isNull);
    });
  });
}
