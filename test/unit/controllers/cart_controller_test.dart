import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:traders_retailer/domain/entities/cart_entity.dart';
import 'package:traders_retailer/domain/entities/cart_item_entity.dart';
import 'package:traders_retailer/domain/entities/product_entity.dart';
import 'package:traders_retailer/domain/repositories/cart_repository.dart';
import 'package:traders_retailer/domain/value_objects/money.dart';
import 'package:traders_retailer/features/cart/controllers/cart_controller.dart';

class MockCartRepository extends Mock implements CartRepository {}

void main() {
  late MockCartRepository repository;
  late StreamController<CartEntity> cartStream;
  late CartController controller;

  final item = CartItemEntity(
    productId: 'p1',
    name: 'Rice 25kg',
    imageUrl: '',
    unitPrice: Money(500),
    unit: ProductUnit.piece,
    qty: 2,
  );

  setUpAll(() {
    registerFallbackValue(item);
  });

  setUp(() {
    repository = MockCartRepository();
    cartStream = StreamController<CartEntity>.broadcast();
    when(() => repository.watchCart()).thenAnswer((_) => cartStream.stream);
    when(() => repository.addItem(any())).thenAnswer((_) async {});
    when(() => repository.removeItem(any())).thenAnswer((_) async {});
    when(() => repository.updateQty(any(), any())).thenAnswer((_) async {});
    when(() => repository.clearCart()).thenAnswer((_) async {});
    controller = CartController(repository);
  });

  tearDown(() => cartStream.close());

  test('starts empty before the repository stream emits', () {
    expect(controller.state, CartEntity.empty);
  });

  test('mirrors whatever the repository stream emits', () async {
    final cart = CartEntity(items: [item]);

    cartStream.add(cart);
    await Future<void>.delayed(Duration.zero);

    expect(controller.state, cart);
  });

  test('addItem delegates to the repository', () async {
    await controller.addItem(item);
    verify(() => repository.addItem(item)).called(1);
  });

  test('removeItem delegates to the repository', () async {
    await controller.removeItem('p1');
    verify(() => repository.removeItem('p1')).called(1);
  });

  test('updateQty delegates to the repository', () async {
    await controller.updateQty('p1', 5);
    verify(() => repository.updateQty('p1', 5)).called(1);
  });

  test('clearCart delegates to the repository', () async {
    await controller.clearCart();
    verify(() => repository.clearCart()).called(1);
  });
}
