import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/domain/entities/address_entity.dart';
import 'package:traders_retailer/domain/entities/order_entity.dart';
import 'package:traders_retailer/domain/entities/order_item_entity.dart';
import 'package:traders_retailer/domain/value_objects/money.dart';
import 'package:traders_retailer/features/profile/controllers/profile_insights_controller.dart';

OrderEntity _order(
  String id,
  DateTime createdAt, {
  double total = 3000,
  OrderStatus status = OrderStatus.delivered,
  List<(String, String)> items = const [('p1', 'Rice')],
}) => OrderEntity(
  id: id,
  userId: 'u1',
  shopName: 'Shop',
  items: [
    for (final (pid, name) in items)
      OrderItemEntity(productId: pid, name: name, qty: 1, unitPrice: Money(10)),
  ],
  subtotal: Money(total),
  deliveryCharge: Money(0),
  paymentMethod: PaymentMethod.cod,
  paymentStatus: PaymentStatus.pending,
  orderStatus: status,
  deliveryAddress: const AddressEntity(
    street: 'St',
    city: 'City',
    pincode: '123456',
  ),
  createdAt: createdAt,
);

void main() {
  // Mid-month, mid-day, so "this month so far" and "same days last month"
  // are both well inside their months.
  final now = DateTime(2026, 9, 15, 12);

  test('no orders (or only cancelled ones) means no card', () {
    expect(computeRetailerInsights(const [], now: now), isNull);
    expect(
      computeRetailerInsights([
        _order('c', now, status: OrderStatus.cancelled),
      ], now: now),
      isNull,
    );
  });

  test('sums this month and compares with the same days of last month', () {
    final insights = computeRetailerInsights([
      _order('a', DateTime(2026, 9, 2), total: 4000),
      _order('b', DateTime(2026, 9, 10), total: 2000),
      // Last month, inside the 1st-15th window -> baseline.
      _order('c', DateTime(2026, 8, 5), total: 3000),
      // Last month but AFTER the 15th -> must not deflate the trend.
      _order('d', DateTime(2026, 8, 25), total: 9000),
    ], now: now)!;

    expect(insights.monthSpend, 6000);
    expect(insights.monthOrders, 2);
    expect(insights.spendTrend, closeTo(100, 1e-9)); // 6000 vs 3000
  });

  test('cancelled orders are ignored everywhere', () {
    final insights = computeRetailerInsights([
      _order('a', DateTime(2026, 9, 2), total: 1000),
      _order(
        'x',
        DateTime(2026, 9, 3),
        total: 50000,
        status: OrderStatus.cancelled,
      ),
    ], now: now)!;

    expect(insights.monthSpend, 1000);
    expect(insights.monthOrders, 1);
  });

  test('trend is null when last month had nothing to compare to', () {
    final insights = computeRetailerInsights([
      _order('a', DateTime(2026, 9, 2)),
    ], now: now)!;
    expect(insights.spendTrend, isNull);
  });

  test('a 31st clamps to a shorter previous month instead of rolling over', () {
    // 31 Mar: February has 28 days, so the window must end 28 Feb, not spill
    // into March.
    final march31 = DateTime(2026, 3, 31, 12);
    final insights = computeRetailerInsights([
      _order('feb', DateTime(2026, 2, 20), total: 1000),
      _order('mar', DateTime(2026, 3, 5), total: 2000),
    ], now: march31)!;
    expect(insights.spendTrend, closeTo(100, 1e-9));
  });

  test('ranks most-bought products by orders, ties broken by name', () {
    final insights = computeRetailerInsights([
      _order('1', DateTime(2026, 9, 1), items: [('r', 'Rice'), ('o', 'Oil')]),
      _order('2', DateTime(2026, 8, 1), items: [('r', 'Rice'), ('s', 'Salt')]),
      _order('3', DateTime(2026, 7, 1), items: [('r', 'Rice')]),
    ], now: now)!;

    expect(insights.topProducts.map((p) => p.name), ['Rice', 'Oil', 'Salt']);
    expect(insights.topProducts.first.orders, 3);
  });

  test('picks the favourite category when products are known', () {
    final insights = computeRetailerInsights(
      [
        _order('1', DateTime(2026, 9, 1), items: [('r', 'Rice'), ('d', 'Dal')]),
        _order('2', DateTime(2026, 9, 2), items: [('o', 'Oil')]),
      ],
      now: now,
      categoryIdByProduct: {'r': 'grains', 'd': 'grains', 'o': 'oils'},
      categoryNameById: {'grains': 'Grains', 'oils': 'Oils'},
    )!;

    expect(insights.topCategory, 'Grains');
  });

  test('no category name when the products are unknown', () {
    final insights = computeRetailerInsights([
      _order('1', DateTime(2026, 9, 1)),
    ], now: now)!;
    expect(insights.topCategory, isNull);
  });
}
