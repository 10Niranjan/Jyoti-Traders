import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:traders_retailer/data/datasources/local/cart_local_datasource.dart';
import 'package:traders_retailer/data/datasources/remote/category_remote_datasource.dart';
import 'package:traders_retailer/data/datasources/remote/order_remote_datasource.dart';
import 'package:traders_retailer/data/datasources/remote/product_remote_datasource.dart';
import 'package:traders_retailer/data/datasources/local/product_local_datasource.dart';
import 'package:traders_retailer/data/repositories/cart_repository_impl.dart';
import 'package:traders_retailer/data/repositories/category_repository_impl.dart';
import 'package:traders_retailer/data/repositories/order_repository_impl.dart';
import 'package:traders_retailer/data/repositories/product_repository_impl.dart';
import 'package:traders_retailer/domain/entities/address_entity.dart';
import 'package:traders_retailer/domain/entities/cart_item_entity.dart';
import 'package:traders_retailer/domain/entities/category_entity.dart';
import 'package:traders_retailer/domain/entities/order_entity.dart';
import 'package:traders_retailer/domain/entities/order_item_entity.dart';
import 'package:traders_retailer/domain/entities/product_entity.dart';
import 'package:traders_retailer/domain/exceptions/domain_exceptions.dart';
import 'package:traders_retailer/domain/usecases/order/place_order_usecase.dart';
import 'package:traders_retailer/domain/value_objects/money.dart';
import 'package:traders_retailer/features/cart/controllers/cart_controller.dart';
import 'package:traders_retailer/features/checkout/controllers/checkout_controller.dart';

/// Phase 7's one genuinely new test: the full retailer journey — browse the
/// simulated catalog, add to cart, place an order, land in order history —
/// driven through the same repositories/controllers the app wires up, not
/// mocks. Follows `simulation_backend_test.dart`'s Hive-temp-dir pattern
/// since this app has no GoRouter/widget test harness for screen-to-screen
/// navigation.
void main() {
  late Box catalogBox;
  late Box ordersBox;
  late Box cartBox;
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('jyoti_kirana_order_flow_test_');
    Hive.init(tempDir.path);
    catalogBox = await Hive.openBox('catalog_cache');
    ordersBox = await Hive.openBox('orders_cache');
    cartBox = await Hive.openBox('cart_box');
  });

  tearDown(() async {
    await Hive.close();
    try {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  test('browse -> cart -> checkout -> success', () async {
    final categoryRepo = CategoryRepositoryImpl(CategoryRemoteDatasource(catalogBox: catalogBox));
    final productRepo = ProductRepositoryImpl(
      ProductRemoteDatasource(catalogBox: catalogBox),
      ProductLocalDatasource(catalogBox: catalogBox),
    );
    final cartRepo = CartRepositoryImpl(CartLocalDatasource(cartBox: cartBox, uid: 'retailer_1'));
    final orderRepo = OrderRepositoryImpl(OrderRemoteDatasource(ordersBox: ordersBox));

    // Browse: seed and fetch a category + product, exactly as HomeScreen/
    // CategoryProductsScreen would.
    await categoryRepo.createCategory(const CategoryEntity(
      id: 'cat_grains',
      name: 'Atta, Rice & Grains',
      iconUrl: '',
      displayOrder: 1,
      isActive: true,
    ));
    await productRepo.createProduct(ProductEntity(
      id: 'prod_rice_25kg',
      name: 'Basmati Rice 25kg',
      categoryId: 'cat_grains',
      imageUrl: '',
      price: Money(1800),
      unit: ProductUnit.box,
      stock: 40,
      isActive: true,
    ));

    final products = await productRepo.watchProducts(categoryId: 'cat_grains').first;
    final product = products.singleWhere((p) => p.id == 'prod_rice_25kg');

    // Cart: add two units via the real CartController, same as ProductCard's
    // quantity sheet does.
    final cartController = CartController(cartRepo);
    await cartController.addItem(CartItemEntity(
      productId: product.id,
      name: product.name,
      imageUrl: product.imageUrl,
      unitPrice: product.price,
      unit: product.unit,
      qty: 2,
    ));

    final cart = await cartRepo.watchCart().first;
    expect(cart.subtotal.amount, 3600);
    expect(cart.subtotal >= Money(2500), isTrue); // clears the minimum-order gate

    // Checkout: place the order via the real CheckoutController, which both
    // writes the order and clears the cart on success.
    final checkoutController = CheckoutController(PlaceOrderUseCase(orderRepo), cartController);
    final order = OrderEntity(
      id: 'order_flow_test',
      userId: 'retailer_1',
      shopName: 'Ramesh Kirana Store',
      items: [OrderItemEntity(productId: product.id, name: product.name, qty: 2, unitPrice: product.price)],
      subtotal: cart.subtotal,
      deliveryCharge: Money(100),
      paymentMethod: PaymentMethod.cod,
      paymentStatus: PaymentStatus.pending,
      orderStatus: OrderStatus.pending,
      deliveryAddress: const AddressEntity(street: 'Main Rd', city: 'Pune', pincode: '411001'),
      createdAt: DateTime(2026, 7, 31),
    );

    await checkoutController.placeOrder(order);

    // Success: order id is the controller's state, cart is empty, and the
    // order shows up in the retailer's own history.
    expect(checkoutController.state.value, 'order_flow_test');
    expect(checkoutController.state.hasError, isFalse);

    final clearedCart = await cartRepo.watchCart().first;
    expect(clearedCart.isEmpty, isTrue);

    final history = await orderRepo.watchOrderHistory('retailer_1').first;
    expect(history.map((o) => o.id), contains('order_flow_test'));
  });

  test('below the ₹2,500 minimum: checkout rejects the order and the cart is untouched', () async {
    final cartRepo = CartRepositoryImpl(CartLocalDatasource(cartBox: cartBox, uid: 'retailer_1'));
    final orderRepo = OrderRepositoryImpl(OrderRemoteDatasource(ordersBox: ordersBox));
    final cartController = CartController(cartRepo);

    await cartController.addItem(CartItemEntity(
      productId: 'prod_rice_25kg',
      name: 'Basmati Rice 25kg',
      imageUrl: '',
      unitPrice: Money(1800),
      unit: ProductUnit.box,
      qty: 1,
    ));
    final cart = await cartRepo.watchCart().first;
    expect(cart.subtotal.amount, 1800); // below the ₹2,500 minimum

    final checkoutController = CheckoutController(PlaceOrderUseCase(orderRepo), cartController);
    final order = OrderEntity(
      id: 'order_should_not_exist',
      userId: 'retailer_1',
      shopName: 'Ramesh Kirana Store',
      items: [OrderItemEntity(productId: 'prod_rice_25kg', name: 'Basmati Rice 25kg', qty: 1, unitPrice: Money(1800))],
      subtotal: cart.subtotal,
      deliveryCharge: Money(100),
      paymentMethod: PaymentMethod.cod,
      paymentStatus: PaymentStatus.pending,
      orderStatus: OrderStatus.pending,
      deliveryAddress: const AddressEntity(street: 'Main Rd', city: 'Pune', pincode: '411001'),
      createdAt: DateTime(2026, 7, 31),
    );

    await checkoutController.placeOrder(order);

    expect(checkoutController.state.hasError, isTrue);
    expect(checkoutController.state.error, isA<MinimumOrderException>());

    final history = await orderRepo.watchOrderHistory('retailer_1').first;
    expect(history.map((o) => o.id), isNot(contains('order_should_not_exist')));

    final untouchedCart = await cartRepo.watchCart().first;
    expect(untouchedCart.isEmpty, isFalse); // cart is not cleared on rejection
  });
}
