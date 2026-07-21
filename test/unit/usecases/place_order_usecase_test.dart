import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:traders_retailer/domain/entities/address_entity.dart';
import 'package:traders_retailer/domain/entities/order_entity.dart';
import 'package:traders_retailer/domain/entities/order_item_entity.dart';
import 'package:traders_retailer/domain/exceptions/domain_exceptions.dart';
import 'package:traders_retailer/domain/repositories/order_repository.dart';
import 'package:traders_retailer/domain/usecases/order/place_order_usecase.dart';
import 'package:traders_retailer/domain/value_objects/money.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  late MockOrderRepository repository;
  late PlaceOrderUseCase useCase;

  setUpAll(() {
    registerFallbackValue(_buildOrder(subtotal: 3000));
  });

  setUp(() {
    repository = MockOrderRepository();
    useCase = PlaceOrderUseCase(repository);
    when(() => repository.placeOrder(any())).thenAnswer((_) async {});
  });

  test('throws MinimumOrderException when subtotal is below ₹2,500', () async {
    final order = _buildOrder(subtotal: 2000);

    expect(() => useCase(order), throwsA(isA<MinimumOrderException>()));
    verifyNever(() => repository.placeOrder(any()));
  });

  test('places the order when subtotal meets the ₹2,500 minimum', () async {
    final order = _buildOrder(subtotal: 2500);

    await useCase(order);

    verify(() => repository.placeOrder(order)).called(1);
  });

  test('places the order when subtotal exceeds the ₹2,500 minimum', () async {
    final order = _buildOrder(subtotal: 5000);

    await useCase(order);

    verify(() => repository.placeOrder(order)).called(1);
  });

  test('delivery charge does not count toward the minimum', () async {
    // Subtotal alone is below minimum even though delivery charge would push
    // the grand total over ₹2,500 — the rule must still block this order.
    final order = _buildOrder(subtotal: 2000, deliveryCharge: 600);

    expect(() => useCase(order), throwsA(isA<MinimumOrderException>()));
  });
}

OrderEntity _buildOrder({required double subtotal, double deliveryCharge = 0}) {
  return OrderEntity(
    id: 'order_1',
    userId: 'user_1',
    shopName: 'Ram Kirana Store',
    items: [
      OrderItemEntity(productId: 'p1', name: 'Rice 25kg', qty: 1, unitPrice: Money(subtotal)),
    ],
    subtotal: Money(subtotal),
    deliveryCharge: Money(deliveryCharge),
    paymentMethod: PaymentMethod.cod,
    paymentStatus: PaymentStatus.pending,
    orderStatus: OrderStatus.pending,
    deliveryAddress: const AddressEntity(street: 'Main Rd', city: 'Pune', pincode: '411001'),
    createdAt: DateTime(2026, 7, 21),
  );
}
