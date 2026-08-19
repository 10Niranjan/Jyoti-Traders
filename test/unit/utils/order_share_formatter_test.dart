import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/core/utils/order_share_formatter.dart';
import 'package:traders_retailer/domain/entities/address_entity.dart';
import 'package:traders_retailer/domain/entities/order_entity.dart';
import 'package:traders_retailer/domain/entities/order_item_entity.dart';
import 'package:traders_retailer/domain/value_objects/money.dart';

void main() {
  group('buildOrderShareText', () {
    test('includes the order id, items, and totals', () {
      final order = OrderEntity(
        id: 'order_abcdefgh1234',
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
        paymentMethod: PaymentMethod.cod,
        paymentStatus: PaymentStatus.pending,
        orderStatus: OrderStatus.pending,
        deliveryAddress: const AddressEntity(
          street: 'St',
          city: 'City',
          pincode: '123456',
        ),
        createdAt: DateTime(2026, 7, 20, 15, 30),
      );

      final text = buildOrderShareText(order);

      expect(text, contains('Order #ORDER_AB'));
      expect(text, contains('Basmati Rice'));
      expect(text, contains('× 2'));
      expect(text, contains('Total: ₹3,050'));
      expect(text, contains('Status: Pending'));
    });
  });
}
