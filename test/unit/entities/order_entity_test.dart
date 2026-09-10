import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/domain/entities/address_entity.dart';
import 'package:traders_retailer/domain/entities/order_entity.dart';
import 'package:traders_retailer/domain/entities/order_item_entity.dart';
import 'package:traders_retailer/domain/value_objects/money.dart';

OrderEntity _order({
  required OrderStatus status,
  required DateTime createdAt,
}) => OrderEntity(
  id: 'o1',
  userId: 'u1',
  shopName: 'Shop',
  items: [
    OrderItemEntity(
      productId: 'p1',
      name: 'Rice',
      qty: 1,
      unitPrice: Money(3000),
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
  createdAt: createdAt,
);

void main() {
  group('OrderEntity.isCancellable', () {
    test('is true for a pending order placed seconds ago', () {
      final order = _order(
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
      );
      expect(order.isCancellable, isTrue);
    });

    test('is false once the cancellation window has passed', () {
      final order = _order(
        status: OrderStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(minutes: 11)),
      );
      expect(order.isCancellable, isFalse);
    });

    test('is false for a non-pending order even if recent', () {
      final order = _order(
        status: OrderStatus.confirmed,
        createdAt: DateTime.now(),
      );
      expect(order.isCancellable, isFalse);
    });
  });
}
