import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:traders_retailer/data/datasources/local/cart_local_datasource.dart';
import 'package:traders_retailer/data/datasources/remote/category_remote_datasource.dart';
import 'package:traders_retailer/data/datasources/remote/order_remote_datasource.dart';
import 'package:traders_retailer/data/datasources/remote/product_remote_datasource.dart';
import 'package:traders_retailer/data/datasources/remote/user_remote_datasource.dart';
import 'package:traders_retailer/data/repositories/cart_repository_impl.dart';
import 'package:traders_retailer/data/repositories/category_repository_impl.dart';
import 'package:traders_retailer/data/repositories/firebase_auth_repository.dart';
import 'package:traders_retailer/data/repositories/order_repository_impl.dart';
import 'package:traders_retailer/data/repositories/product_repository_impl.dart';
import 'package:traders_retailer/data/repositories/user_repository_impl.dart';
import 'package:traders_retailer/data/datasources/local/product_local_datasource.dart';
import 'package:traders_retailer/domain/entities/address_entity.dart';
import 'package:traders_retailer/domain/entities/cart_item_entity.dart';
import 'package:traders_retailer/domain/entities/category_entity.dart';
import 'package:traders_retailer/domain/entities/order_entity.dart';
import 'package:traders_retailer/domain/entities/order_item_entity.dart';
import 'package:traders_retailer/domain/entities/product_entity.dart';
import 'package:traders_retailer/domain/value_objects/money.dart';
import 'package:traders_retailer/data/models/user_model.dart';

/// Firebase is still on placeholder credentials (see `firebase_options.dart`)
/// — there is no live Firestore project connected to this app yet. Every
/// repository built in Phase 2 falls back to a Hive-backed simulation mode
/// in that case, which is what actually runs today. This test exercises
/// that simulation layer end-to-end, standing in for a "does the backend
/// work" check since there is no real backend to hit.
void main() {
  late Box userCacheBox;
  late Box catalogBox;
  late Box ordersBox;
  late Box cartBox;

  setUp(() async {
    // Unique per-test-run directory — a fixed shared path can be left behind
    // by a previous run on Windows if `deleteFromDisk` races with file-handle
    // release, which would leak state (e.g. a "user already exists") into
    // the next run.
    Hive.init('temp_hive_integration_${DateTime.now().microsecondsSinceEpoch}');
    userCacheBox = await Hive.openBox('user_cache');
    catalogBox = await Hive.openBox('catalog_cache');
    ordersBox = await Hive.openBox('orders_cache');
    cartBox = await Hive.openBox('cart_box');
  });

  tearDown(() async {
    await Hive.close();
    await Hive.deleteFromDisk();
  });

  test('retailer sign-up starts pending, then admin approval flips it to approved', () async {
    final authRepo = FirebaseAuthRepository(userCacheBox: userCacheBox);
    final userRepo = UserRepositoryImpl(UserRemoteDatasource(userCacheBox: userCacheBox));

    final retailer = await authRepo.signUp(
      name: 'Ramesh Bhai',
      email: 'ramesh@example.com',
      password: 'password123',
      phone: '9876543210',
      role: UserRole.customer,
      businessName: 'Ramesh Kirana Store',
    );

    expect(retailer, isNotNull);
    expect(retailer!.isApproved, isFalse);

    final pending = await userRepo.watchPendingUsers().first;
    expect(pending.map((u) => u.uid), contains(retailer.uid));

    await userRepo.approveUser(retailer.uid);

    final refreshed = await authRepo.refreshUserStatus(retailer.uid);
    expect(refreshed!.isApproved, isTrue);

    final approvedList = await userRepo.getApprovedUsers();
    expect(approvedList.map((u) => u.uid), contains(retailer.uid));
  });

  test('category and product CRUD round-trips through the simulated catalog', () async {
    final categoryRepo = CategoryRepositoryImpl(CategoryRemoteDatasource(catalogBox: catalogBox));
    final productRepo = ProductRepositoryImpl(
      ProductRemoteDatasource(catalogBox: catalogBox),
      ProductLocalDatasource(catalogBox: catalogBox),
    );

    await categoryRepo.createCategory(const CategoryEntity(
      id: 'cat_grains',
      name: 'Atta, Rice & Grains',
      iconUrl: '',
      displayOrder: 1,
      isActive: true,
    ));

    final categories = await categoryRepo.watchCategories().first;
    expect(categories.map((c) => c.id), contains('cat_grains'));

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
    expect(products.map((p) => p.id), contains('prod_rice_25kg'));

    final searchResults = await productRepo.searchProducts('basmati');
    expect(searchResults, isNotEmpty);
  });

  test('deactivated products stay visible to the admin but disappear from retailer browsing', () async {
    final productRepo = ProductRepositoryImpl(
      ProductRemoteDatasource(catalogBox: catalogBox),
      ProductLocalDatasource(catalogBox: catalogBox),
    );

    await productRepo.createProduct(ProductEntity(
      id: 'prod_active',
      name: 'Active Product',
      categoryId: 'cat_grains',
      imageUrl: '',
      price: Money(500),
      unit: ProductUnit.kg,
      stock: 10,
      isActive: true,
    ));
    await productRepo.createProduct(ProductEntity(
      id: 'prod_hidden',
      name: 'Hidden Product',
      categoryId: 'cat_grains',
      imageUrl: '',
      price: Money(500),
      unit: ProductUnit.kg,
      stock: 10,
      isActive: false,
    ));

    // Retailer browsing must not surface the inactive one...
    final browsable = await productRepo.watchProducts().first;
    expect(browsable.map((p) => p.id), contains('prod_active'));
    expect(browsable.map((p) => p.id), isNot(contains('prod_hidden')));

    // ...but the admin list must, or a deactivated product could never be
    // found again to re-activate it.
    final allForAdmin = await productRepo.watchAllProducts().first;
    expect(allForAdmin.map((p) => p.id), containsAll(['prod_active', 'prod_hidden']));
  });

  test('cart add/update/clear round-trips through Hive', () async {
    final cartRepo = CartRepositoryImpl(CartLocalDatasource(cartBox: cartBox));

    await cartRepo.addItem(CartItemEntity(
      productId: 'prod_rice_25kg',
      name: 'Basmati Rice 25kg',
      imageUrl: '',
      unitPrice: Money(1800),
      unit: ProductUnit.box,
      qty: 2,
    ));

    var cart = await cartRepo.watchCart().first;
    expect(cart.itemCount, 2);
    expect(cart.subtotal.amount, 3600);

    await cartRepo.updateQty('prod_rice_25kg', 1);
    cart = await cartRepo.watchCart().first;
    expect(cart.subtotal.amount, 1800);

    await cartRepo.clearCart();
    cart = await cartRepo.watchCart().first;
    expect(cart.isEmpty, isTrue);
  });

  test('order placement and status update round-trip through the simulated orders store', () async {
    final orderRepo = OrderRepositoryImpl(OrderRemoteDatasource(ordersBox: ordersBox));

    final order = OrderEntity(
      id: 'order_test_1',
      userId: 'user_1',
      shopName: 'Ramesh Kirana Store',
      items: [
        OrderItemEntity(productId: 'prod_rice_25kg', name: 'Basmati Rice 25kg', qty: 2, unitPrice: Money(1800)),
      ],
      subtotal: Money(3600),
      deliveryCharge: Money(100),
      paymentMethod: PaymentMethod.cod,
      paymentStatus: PaymentStatus.pending,
      orderStatus: OrderStatus.pending,
      deliveryAddress: const AddressEntity(street: 'Main Rd', city: 'Pune', pincode: '411001'),
      createdAt: DateTime(2026, 7, 21),
    );

    await orderRepo.placeOrder(order);

    final history = await orderRepo.watchOrderHistory('user_1').first;
    expect(history.map((o) => o.id), contains('order_test_1'));

    await orderRepo.updateOrderStatus('order_test_1', OrderStatus.confirmed);

    final allOrders = await orderRepo.watchAllOrders().first;
    final updated = allOrders.firstWhere((o) => o.id == 'order_test_1');
    expect(updated.orderStatus, OrderStatus.confirmed);
  });
}
