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
import 'package:traders_retailer/domain/entities/notification_preferences_entity.dart';
import 'package:traders_retailer/domain/entities/order_entity.dart';
import 'package:traders_retailer/domain/entities/order_item_entity.dart';
import 'package:traders_retailer/domain/entities/product_entity.dart';
import 'package:traders_retailer/domain/repositories/order_repository.dart';
import 'package:traders_retailer/domain/repositories/product_repository.dart';
import 'package:traders_retailer/domain/value_objects/money.dart';
import 'package:traders_retailer/features/orders/screens/order_history_screen.dart';
import 'package:traders_retailer/l10n/app_localizations.dart';

import '../helpers/fake_cart_repository.dart';

/// Minimal fake, same shape as the one in order_detail_screen_test.dart —
/// just enough of `AuthRepository` to reach `AuthenticatedCustomer`, which
/// `orderHistoryProvider` requires.
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
    List<AddressEntity>? savedAddresses,
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
  FakeOrderRepository(this.orders);

  @override
  Stream<List<OrderEntity>> watchAllOrders() => Stream.value(orders);

  @override
  Future<void> placeOrder(OrderEntity order) async {}

  @override
  Stream<List<OrderEntity>> watchOrderHistory(String userId) =>
      Stream.value(orders);

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {}

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
  Stream<List<ProductEntity>> watchProducts({String? categoryId}) => Stream.value(products.values.toList());

  @override
  Stream<List<ProductEntity>> watchAllProducts() => Stream.value(products.values.toList());

  @override
  Future<List<ProductEntity>> searchProducts(String query) async => [];

  @override
  Future<ProductEntity?> getProductById(String productId) async => products[productId];

  @override
  Future<void> createProduct(ProductEntity product) async {}

  @override
  Future<void> updateProduct(ProductEntity product) async {}

  @override
  Future<void> deleteProduct(String productId) async {}
}

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

OrderEntity _order({required String id, required OrderStatus status}) =>
    OrderEntity(
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
      createdAt: DateTime(2026, 7, 20),
    );

Widget _wrap(FakeOrderRepository repo, {FakeProductRepository? productRepo, FakeCartRepository? cartRepo}) =>
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(FakeAuthRepository(_retailer)),
        orderRepositoryProvider.overrideWithValue(repo),
        productRepositoryProvider.overrideWithValue(productRepo ?? FakeProductRepository({'p1': _product})),
        cartRepositoryProvider.overrideWithValue(cartRepo ?? FakeCartRepository()),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: OrderHistoryScreen(),
      ),
    );

void main() {
  testWidgets('shows an empty state when there are no orders', (tester) async {
    await tester.pumpWidget(_wrap(FakeOrderRepository([])));
    await tester.pumpAndSettle();

    expect(find.text('No orders yet'), findsOneWidget);
  });

  testWidgets('lists every order by default', (tester) async {
    await tester.pumpWidget(
      _wrap(
        FakeOrderRepository([
          _order(id: 'o1', status: OrderStatus.pending),
          _order(id: 'o2', status: OrderStatus.delivered),
        ]),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Order #${'o1'.toUpperCase()}'), findsOneWidget);
    expect(find.text('Order #${'o2'.toUpperCase()}'), findsOneWidget);
  });

  testWidgets('filtering by status hides orders in other statuses', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        FakeOrderRepository([
          _order(id: 'o1', status: OrderStatus.pending),
          _order(id: 'o2', status: OrderStatus.delivered),
        ]),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilterChip, 'Delivered'));
    await tester.pumpAndSettle();

    expect(find.text('Order #${'o1'.toUpperCase()}'), findsNothing);
    expect(find.text('Order #${'o2'.toUpperCase()}'), findsOneWidget);
  });

  testWidgets(
    'shows a status-specific empty message when a filter matches nothing',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          FakeOrderRepository([_order(id: 'o1', status: OrderStatus.pending)]),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilterChip, 'Delivered'));
      await tester.pumpAndSettle();

      expect(find.text('No delivered orders'), findsOneWidget);
    },
  );

  testWidgets('tapping Reorder on a row adds the live-priced item to the cart', (tester) async {
    final cartRepo = FakeCartRepository();
    await tester.pumpWidget(
      _wrap(
        FakeOrderRepository([_order(id: 'o1', status: OrderStatus.delivered)]),
        cartRepo: cartRepo,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Buy Again'));
    await tester.pumpAndSettle();

    expect(cartRepo.items, hasLength(1));
    expect(cartRepo.items.single.productId, 'p1');
    expect(find.textContaining('1 item added to cart'), findsOneWidget);
  });
}
