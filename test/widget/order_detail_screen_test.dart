import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/data/models/user_model.dart';
import 'package:traders_retailer/data/repositories/auth_repository.dart';
import 'package:traders_retailer/data/repositories/auth_repository_provider.dart';
import 'package:traders_retailer/data/repositories/repository_providers.dart';
import 'package:traders_retailer/domain/entities/address_entity.dart';
import 'package:traders_retailer/domain/entities/bank_details_entity.dart';
import 'package:traders_retailer/domain/entities/business_hours_entity.dart';
import 'package:traders_retailer/domain/entities/cart_item_entity.dart';
import 'package:traders_retailer/domain/entities/notification_preferences_entity.dart';
import 'package:traders_retailer/domain/entities/order_entity.dart';
import 'package:traders_retailer/domain/entities/order_item_entity.dart';
import 'package:traders_retailer/domain/entities/product_entity.dart';
import 'package:traders_retailer/domain/repositories/order_repository.dart';
import 'package:traders_retailer/domain/repositories/product_repository.dart';
import 'package:traders_retailer/domain/value_objects/money.dart';
import 'package:traders_retailer/features/orders/screens/order_detail_screen.dart';

import '../helpers/fake_cart_repository.dart';
import '../helpers/test_viewport.dart';

/// Minimal fake, mirroring the one in upi_payment_screen_test.dart — just
/// enough of `AuthRepository` to reach `AuthenticatedCustomer`.
class FakeAuthRepository implements AuthRepository {
  final UserModel user;
  FakeAuthRepository(this.user);

  @override
  Stream<UserModel?> get authStateChanges => Stream.value(user);

  @override
  Future<UserModel?> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
    required UserRole role,
    required String businessName,
  }) async => user;

  @override
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async => user;

  @override
  Future<void> signOut() async {}

  @override
  Future<UserModel?> getCurrentUser() async => user;

  @override
  Future<UserModel?> refreshUserStatus(String uid) async => user;

  @override
  Future<UserModel?> updateProfile({
    required String uid,
    String? name,
    String? phone,
    String? businessName,
    String? photoUrl,
    AddressEntity? address,
    String? gstNumber,
    BankDetailsEntity? bankDetails,
    BusinessHoursEntity? businessHours,
    NotificationPreferencesEntity? notificationPreferences,
  }) async => user;

  @override
  Future<void> updateFcmToken({
    required String uid,
    required String fcmToken,
  }) async {}

  @override
  Future<void> sendPasswordResetEmail(String email) async {}
}

class FakeOrderRepository implements OrderRepository {
  final List<OrderEntity> orders;
  final List<(String, OrderStatus)> statusUpdates = [];
  FakeOrderRepository(this.orders);

  @override
  Stream<List<OrderEntity>> watchAllOrders() => Stream.value(orders);

  @override
  Future<void> placeOrder(OrderEntity order) async {}

  @override
  Stream<List<OrderEntity>> watchOrderHistory(String userId) =>
      Stream.value(orders);

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    statusUpdates.add((orderId, status));
  }

  @override
  Future<void> recordPaymentClaim(
    String orderId, {
    String? screenshotUrl,
  }) async {}

  @override
  Future<void> updatePaymentStatus(
    String orderId,
    PaymentStatus status,
  ) async {}
}

class FakeProductRepository implements ProductRepository {
  final Map<String, ProductEntity> products;
  FakeProductRepository(this.products);

  @override
  Stream<List<ProductEntity>> watchProducts({String? categoryId}) =>
      Stream.value(products.values.toList());

  @override
  Stream<List<ProductEntity>> watchAllProducts() =>
      Stream.value(products.values.toList());

  @override
  Future<List<ProductEntity>> searchProducts(String query) async => [];

  @override
  Future<ProductEntity?> getProductById(String productId) async =>
      products[productId];

  @override
  Future<void> createProduct(ProductEntity product) async {}

  @override
  Future<void> updateProduct(ProductEntity product) async {}

  @override
  Future<void> deleteProduct(String productId) async {}
}

final _retailer = UserModel(
  uid: 'u1',
  name: 'Ramesh',
  email: 'ramesh@test.com',
  phone: '9876543210',
  role: UserRole.customer,
  status: UserStatus.approved,
  businessName: 'Ramesh Kirana Store',
  createdAt: DateTime(2026, 1, 1),
);

OrderEntity _order({
  String id = 'o1',
  OrderStatus status = OrderStatus.pending,
  DateTime? createdAt,
}) => OrderEntity(
  id: id,
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
  orderStatus: status,
  deliveryAddress: const AddressEntity(
    street: 'St',
    city: 'City',
    pincode: '123456',
  ),
  createdAt: createdAt ?? DateTime.now(),
);

final _product = ProductEntity(
  id: 'p1',
  name: 'Basmati Rice',
  categoryId: 'c1',
  imageUrl: '',
  price: Money(1500),
  unit: ProductUnit.box,
  stock: 10,
  isActive: true,
);

Widget _wrap({
  required FakeOrderRepository orderRepo,
  FakeProductRepository? productRepo,
  FakeCartRepository? cartRepo,
  String orderId = 'o1',
}) => ProviderScope(
  overrides: [
    authRepositoryProvider.overrideWithValue(FakeAuthRepository(_retailer)),
    orderRepositoryProvider.overrideWithValue(orderRepo),
    productRepositoryProvider.overrideWithValue(
      productRepo ?? FakeProductRepository({'p1': _product}),
    ),
    cartRepositoryProvider.overrideWithValue(cartRepo ?? FakeCartRepository()),
  ],
  child: MaterialApp(home: OrderDetailScreen(orderId: orderId)),
);

void main() {
  useTallTestViewport();

  testWidgets('shows a not-found state for an unknown order id', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(orderRepo: FakeOrderRepository([_order()]), orderId: 'missing'),
    );
    await tester.pumpAndSettle();

    expect(find.text('This order could not be found.'), findsOneWidget);
  });

  testWidgets(
    'tapping the share action attempts the share sheet without crashing',
    (tester) async {
      // No real platform binding in a widget test — the call is wrapped
      // defensively (same pattern as every other platform-plugin call in this
      // codebase) and degrades to a debug print either way.
      await tester.pumpWidget(
        _wrap(orderRepo: FakeOrderRepository([_order()])),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.ios_share_rounded));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Buy Again re-adds an available item to the cart, priced off the live product',
    (tester) async {
      final cartRepo = FakeCartRepository();
      await tester.pumpWidget(
        _wrap(orderRepo: FakeOrderRepository([_order()]), cartRepo: cartRepo),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(OutlinedButton, 'Buy Again'));
      await tester.pumpAndSettle();

      expect(cartRepo.items, [
        CartItemEntity(
          productId: 'p1',
          name: 'Basmati Rice',
          imageUrl: '',
          unitPrice: Money(1500),
          unit: ProductUnit.box,
          qty: 2,
        ),
      ]);
      expect(find.text('1 item added to cart.'), findsOneWidget);
      expect(find.text('VIEW CART'), findsOneWidget);
    },
  );

  testWidgets('Buy Again skips an item whose product no longer exists', (
    tester,
  ) async {
    final cartRepo = FakeCartRepository();
    await tester.pumpWidget(
      _wrap(
        orderRepo: FakeOrderRepository([_order()]),
        productRepo: FakeProductRepository({}),
        cartRepo: cartRepo,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(OutlinedButton, 'Buy Again'));
    await tester.pumpAndSettle();

    expect(cartRepo.items, isEmpty);
    expect(
      find.text('0 items added to cart — 1 no longer available.'),
      findsOneWidget,
    );
    expect(find.text('VIEW CART'), findsNothing);
  });

  testWidgets(
    'a fresh pending order can be cancelled after confirming the dialog',
    (tester) async {
      final repo = FakeOrderRepository([_order()]);
      await tester.pumpWidget(_wrap(orderRepo: repo));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(OutlinedButton, 'Cancel'), findsOneWidget);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Cancel this order?'), findsOneWidget);

      await tester.tap(find.text('Yes, Cancel'));
      await tester.pumpAndSettle();

      expect(repo.statusUpdates, [('o1', OrderStatus.cancelled)]);
      expect(find.text('Order cancelled.'), findsOneWidget);
    },
  );

  testWidgets('dismissing the cancel dialog makes no repository call', (
    tester,
  ) async {
    final repo = FakeOrderRepository([_order()]);
    await tester.pumpWidget(_wrap(orderRepo: repo));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(OutlinedButton, 'Cancel'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('No'));
    await tester.pumpAndSettle();

    expect(repo.statusUpdates, isEmpty);
  });

  testWidgets('an order past the cancellation window hides the Cancel button', (
    tester,
  ) async {
    final oldOrder = _order(
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    );
    await tester.pumpWidget(_wrap(orderRepo: FakeOrderRepository([oldOrder])));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(OutlinedButton, 'Cancel'), findsNothing);
  });

  testWidgets('a confirmed order hides the Cancel button even if recent', (
    tester,
  ) async {
    final confirmedOrder = _order(status: OrderStatus.confirmed);
    await tester.pumpWidget(
      _wrap(orderRepo: FakeOrderRepository([confirmedOrder])),
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(OutlinedButton, 'Cancel'), findsNothing);
  });
}
