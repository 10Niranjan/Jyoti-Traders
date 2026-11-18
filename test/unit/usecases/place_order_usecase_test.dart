import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:traders_retailer/domain/entities/address_entity.dart';
import 'package:traders_retailer/domain/entities/order_entity.dart';
import 'package:traders_retailer/domain/entities/order_item_entity.dart';
import 'package:traders_retailer/domain/entities/product_entity.dart';
import 'package:traders_retailer/domain/exceptions/domain_exceptions.dart';
import 'package:traders_retailer/domain/repositories/order_repository.dart';
import 'package:traders_retailer/domain/repositories/product_repository.dart';
import 'package:traders_retailer/domain/usecases/order/place_order_usecase.dart';
import 'package:traders_retailer/domain/usecases/order/update_order_status_usecase.dart';
import 'package:traders_retailer/domain/value_objects/money.dart';
import 'package:traders_retailer/domain/value_objects/weight_rate_slabs.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late MockOrderRepository repository;
  late MockProductRepository products;
  late PlaceOrderUseCase useCase;

  setUpAll(() {
    registerFallbackValue(_buildOrder(subtotal: 3000));
    registerFallbackValue(_product(stock: 1));
    registerFallbackValue(OrderStatus.pending);
  });

  setUp(() {
    repository = MockOrderRepository();
    products = MockProductRepository();
    useCase = PlaceOrderUseCase(repository, products);
    when(() => repository.placeOrder(any())).thenAnswer((_) async {});
    when(
      () => repository.updateOrderStatus(any(), any()),
    ).thenAnswer((_) async {});
    when(
      () => products.getProductById('p1'),
    ).thenAnswer((_) async => _product(stock: 10));
    when(() => products.updateProduct(any())).thenAnswer((_) async {});
  });

  ProductEntity savedProduct() =>
      verify(() => products.updateProduct(captureAny())).captured.single
          as ProductEntity;

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

  group('stock', () {
    test('takes the ordered quantity out of stock', () async {
      await useCase(_buildOrder(subtotal: 3000, qty: 3));

      expect(savedProduct().stock, 7);
    });

    test(
      'a weighed line takes kilos: 2.5 kg out of 50 kg leaves 47.5 kg',
      () async {
        when(
          () => products.getProductById('p1'),
        ).thenAnswer((_) async => _product(stock: 50, weighed: true));

        await useCase(_buildOrder(subtotal: 3000, qty: 2500, weighed: true));

        expect(savedProduct().stock, 47.5);
      },
    );

    test(
      'more than is in stock: rejected with what is left, nothing placed',
      () async {
        when(
          () => products.getProductById('p1'),
        ).thenAnswer((_) async => _product(stock: 2));

        await expectLater(
          useCase(_buildOrder(subtotal: 3000, qty: 3)),
          throwsA(
            isA<InsufficientStockException>().having(
              (e) => e.available,
              'available',
              '2 box',
            ),
          ),
        );
        verifyNever(() => repository.placeOrder(any()));
        verifyNever(() => products.updateProduct(any()));
      },
    );

    test(
      'a failed stock write after saving still counts as placed (no retry, no double order)',
      () async {
        when(
          () => products.updateProduct(any()),
        ).thenThrow(Exception('permission-denied'));

        await useCase(_buildOrder(subtotal: 3000, qty: 3));

        verify(() => repository.placeOrder(any())).called(1);
      },
    );

    test('a deleted or sold-out product is rejected as unavailable', () async {
      when(() => products.getProductById('p1')).thenAnswer((_) async => null);

      await expectLater(
        useCase(_buildOrder(subtotal: 3000)),
        throwsA(
          isA<InsufficientStockException>().having(
            (e) => e.available,
            'available',
            isNull,
          ),
        ),
      );
      verifyNever(() => repository.placeOrder(any()));
    });
  });

  group('cancelling gives stock back', () {
    late UpdateOrderStatusUseCase updateStatus;

    setUp(() => updateStatus = UpdateOrderStatusUseCase(repository, products));

    test('pending -> cancelled puts the quantity back', () async {
      await updateStatus(
        _buildOrder(subtotal: 3000, qty: 3),
        OrderStatus.cancelled,
      );

      expect(savedProduct().stock, 13);
    });

    test('cancelled -> confirmed takes it again', () async {
      await updateStatus(
        _buildOrder(subtotal: 3000, qty: 3, status: OrderStatus.cancelled),
        OrderStatus.confirmed,
      );

      expect(savedProduct().stock, 7);
    });

    test('a normal status move leaves stock alone', () async {
      await updateStatus(
        _buildOrder(subtotal: 3000, qty: 3),
        OrderStatus.confirmed,
      );

      verifyNever(() => products.updateProduct(any()));
    });
  });
}

ProductEntity _product({required double stock, bool weighed = false}) {
  return ProductEntity(
    id: 'p1',
    name: 'Rice 25kg',
    categoryId: 'c1',
    imageUrl: '',
    price: Money(100),
    unit: weighed ? ProductUnit.kg : ProductUnit.box,
    stock: stock,
    isActive: true,
    rateSlabs: weighed ? WeightRateSlabs.defaults : null,
  );
}

OrderEntity _buildOrder({
  required double subtotal,
  double deliveryCharge = 0,
  int qty = 1,
  bool weighed = false,
  OrderStatus status = OrderStatus.pending,
}) {
  return OrderEntity(
    id: 'order_1',
    userId: 'user_1',
    shopName: 'Ram Kirana Store',
    items: [
      OrderItemEntity(
        productId: 'p1',
        name: 'Rice 25kg',
        qty: qty,
        unitPrice: Money(subtotal),
        unit: weighed ? ProductUnit.kg : null,
        lineTotal: weighed ? Money(subtotal) : null,
      ),
    ],
    subtotal: Money(subtotal),
    deliveryCharge: Money(deliveryCharge),
    paymentMethod: PaymentMethod.cod,
    paymentStatus: PaymentStatus.pending,
    orderStatus: status,
    deliveryAddress: const AddressEntity(
      street: 'Main Rd',
      city: 'Pune',
      pincode: '411001',
    ),
    createdAt: DateTime(2026, 7, 21),
  );
}
