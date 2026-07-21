import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:traders_retailer/domain/entities/address_entity.dart';
import 'package:traders_retailer/domain/entities/order_entity.dart';
import 'package:traders_retailer/domain/entities/order_item_entity.dart';
import 'package:traders_retailer/domain/exceptions/domain_exceptions.dart';
import 'package:traders_retailer/domain/repositories/order_repository.dart';
import 'package:traders_retailer/domain/usecases/order/place_order_usecase.dart';
import 'package:traders_retailer/domain/value_objects/money.dart';
import 'package:traders_retailer/features/cart/controllers/cart_controller.dart';
import 'package:traders_retailer/features/checkout/controllers/checkout_controller.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

class MockCartController extends Mock implements CartController {}

void main() {
  late MockOrderRepository orderRepository;
  late MockCartController cartController;
  late CheckoutController controller;

  setUpAll(() {
    registerFallbackValue(_buildOrder(subtotal: 3000));
  });

  setUp(() {
    orderRepository = MockOrderRepository();
    cartController = MockCartController();
    when(() => orderRepository.placeOrder(any())).thenAnswer((_) async {});
    when(() => cartController.clearCart()).thenAnswer((_) async {});
    controller = CheckoutController(PlaceOrderUseCase(orderRepository), cartController);
  });

  test('below the ₹2,500 minimum: neither places the order nor clears the cart', () async {
    final order = _buildOrder(subtotal: 2000);

    await controller.placeOrder(order);

    expect(controller.state.hasError, isTrue);
    expect(controller.state.error, isA<MinimumOrderException>());
    verifyNever(() => orderRepository.placeOrder(any()));
    verifyNever(() => cartController.clearCart());
  });

  test('at or above the ₹2,500 minimum: places the order and clears the cart', () async {
    final order = _buildOrder(subtotal: 2500);

    await controller.placeOrder(order);

    expect(controller.state.value, order.id);
    verify(() => orderRepository.placeOrder(order)).called(1);
    verify(() => cartController.clearCart()).called(1);
  });

  test('a repository failure surfaces as AsyncError without clearing the cart', () async {
    when(() => orderRepository.placeOrder(any())).thenThrow(Exception('network down'));
    final order = _buildOrder(subtotal: 3000);

    await controller.placeOrder(order);

    expect(controller.state.hasError, isTrue);
    verifyNever(() => cartController.clearCart());
  });
}

OrderEntity _buildOrder({required double subtotal}) {
  return OrderEntity(
    id: 'order_checkout_test',
    userId: 'user_1',
    shopName: 'Ramesh Kirana Store',
    items: [
      OrderItemEntity(productId: 'p1', name: 'Rice 25kg', qty: 1, unitPrice: Money(subtotal)),
    ],
    subtotal: Money(subtotal),
    deliveryCharge: Money(100),
    paymentMethod: PaymentMethod.cod,
    paymentStatus: PaymentStatus.pending,
    orderStatus: OrderStatus.pending,
    deliveryAddress: const AddressEntity(street: 'Main Rd', city: 'Pune', pincode: '411001'),
    createdAt: DateTime(2026, 7, 21),
  );
}
