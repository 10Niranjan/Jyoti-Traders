import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/data/models/user_model.dart';
import 'package:traders_retailer/data/repositories/auth_repository.dart';
import 'package:traders_retailer/data/repositories/auth_repository_provider.dart';
import 'package:traders_retailer/data/repositories/repository_providers.dart';
import 'package:traders_retailer/domain/entities/address_entity.dart';
import 'package:traders_retailer/domain/entities/bank_details_entity.dart';
import 'package:traders_retailer/domain/entities/business_hours_entity.dart';
import 'package:traders_retailer/domain/entities/notification_entity.dart';
import 'package:traders_retailer/domain/entities/notification_preferences_entity.dart';
import 'package:traders_retailer/domain/entities/order_entity.dart';
import 'package:traders_retailer/domain/entities/order_item_entity.dart';
import 'package:traders_retailer/domain/entities/product_entity.dart';
import 'package:traders_retailer/domain/repositories/notification_repository.dart';
import 'package:traders_retailer/domain/repositories/order_repository.dart';
import 'package:traders_retailer/domain/repositories/product_repository.dart';
import 'package:traders_retailer/domain/value_objects/money.dart';
import 'package:traders_retailer/features/notifications/controllers/stock_alert_controller.dart';

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
  final _controller = StreamController<List<ProductEntity>>.broadcast();
  List<ProductEntity> products;
  FakeProductRepository(this.products);

  void emit(List<ProductEntity> next) {
    products = next;
    _controller.add(next);
  }

  @override
  Stream<List<ProductEntity>> watchProducts({String? categoryId}) async* {
    yield products;
    yield* _controller.stream;
  }

  @override
  Stream<List<ProductEntity>> watchAllProducts() => watchProducts();

  @override
  Future<List<ProductEntity>> searchProducts(String query) async => [];

  @override
  Future<ProductEntity?> getProductById(String productId) async {
    final matches = products.where((p) => p.id == productId);
    return matches.isEmpty ? null : matches.first;
  }

  @override
  Future<void> createProduct(ProductEntity product) async {}

  @override
  Future<void> updateProduct(ProductEntity product) async {}

  @override
  Future<void> deleteProduct(String productId) async {}
}

class FakeNotificationRepository implements NotificationRepository {
  final List<NotificationEntity> added = [];

  @override
  Stream<List<NotificationEntity>> watchNotifications() => Stream.value(added);

  @override
  Future<void> addNotification(NotificationEntity notification) async {
    added.add(notification);
  }

  @override
  Future<void> markAsRead(String id) async {}

  @override
  Future<void> markAllAsRead() async {}
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

OrderEntity _orderWith(String productId, {String id = 'o1'}) => OrderEntity(
  id: id,
  userId: 'u1',
  shopName: 'Ramesh Kirana Store',
  items: [
    OrderItemEntity(
      productId: productId,
      name: 'Item',
      qty: 1,
      unitPrice: Money(100),
    ),
  ],
  subtotal: Money(3000),
  deliveryCharge: Money(50),
  paymentMethod: PaymentMethod.cod,
  paymentStatus: PaymentStatus.pending,
  orderStatus: OrderStatus.delivered,
  deliveryAddress: const AddressEntity(
    street: 'St',
    city: 'City',
    pincode: '123456',
  ),
  createdAt: DateTime(2026, 7, 20),
);

ProductEntity _product({required String id, required int stock}) =>
    ProductEntity(
      id: id,
      name: 'Basmati Rice',
      categoryId: 'c1',
      imageUrl: '',
      price: Money(1500),
      unit: ProductUnit.box,
      stock: stock,
      isActive: true,
    );

/// Several event-loop turns are needed for a change to propagate all the way
/// through: auth stream -> `authControllerProvider` -> `orderHistoryProvider`
/// (a fresh stream subscription) -> the derived providers -> `ref.listen`.
/// A single `Future.delayed(Duration.zero)` only drains microtasks queued so
/// far, not ones a later microtask goes on to schedule, so this pumps
/// several turns rather than guessing exactly how many hops are needed.
Future<void> _settle([int turns = 10]) async {
  for (var i = 0; i < turns; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

ProviderContainer _container({
  required List<OrderEntity> orders,
  required FakeProductRepository productRepo,
  required FakeNotificationRepository notificationRepo,
}) {
  final container = ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(FakeAuthRepository(_retailer)),
      orderRepositoryProvider.overrideWithValue(FakeOrderRepository(orders)),
      productRepositoryProvider.overrideWithValue(productRepo),
      notificationRepositoryProvider.overrideWithValue(notificationRepo),
    ],
  );
  return container;
}

void main() {
  group('frequentlyBoughtProductIdsProvider', () {
    test(
      'includes a product ordered at least twice, excludes one ordered once',
      () async {
        final container = _container(
          orders: [
            _orderWith('p1', id: 'o1'),
            _orderWith('p1', id: 'o2'),
            _orderWith('p2', id: 'o3'),
          ],
          productRepo: FakeProductRepository([]),
          notificationRepo: FakeNotificationRepository(),
        );
        addTearDown(container.dispose);
        container.listen(frequentlyBoughtProductIdsProvider, (_, _) {});

        await _settle();
        expect(container.read(frequentlyBoughtProductIdsProvider), {'p1'});
      },
    );
  });

  group('lowStockFrequentProductsProvider', () {
    test(
      'only includes frequent products at/below the low-stock threshold',
      () async {
        final productRepo = FakeProductRepository([
          _product(id: 'p1', stock: 3), // frequent + low
          _product(id: 'p2', stock: 20), // frequent + healthy stock
        ]);
        final container = _container(
          orders: [
            _orderWith('p1', id: 'o1'),
            _orderWith('p1', id: 'o2'),
            _orderWith('p2', id: 'o3'),
            _orderWith('p2', id: 'o4'),
          ],
          productRepo: productRepo,
          notificationRepo: FakeNotificationRepository(),
        );
        addTearDown(container.dispose);
        container.listen(lowStockFrequentProductsProvider, (_, _) {});

        await _settle();

        expect(
          container.read(lowStockFrequentProductsProvider).map((p) => p.id),
          ['p1'],
        );
      },
    );
  });

  group('stockAlertInitializerProvider', () {
    test(
      'writes one local notification for a frequently-bought product that just went low',
      () async {
        final notificationRepo = FakeNotificationRepository();
        final container = _container(
          orders: [
            _orderWith('p1', id: 'o1'),
            _orderWith('p1', id: 'o2'),
          ],
          productRepo: FakeProductRepository([_product(id: 'p1', stock: 3)]),
          notificationRepo: notificationRepo,
        );
        addTearDown(container.dispose);

        container.read(stockAlertInitializerProvider);
        await _settle();

        expect(notificationRepo.added, hasLength(1));
        expect(
          notificationRepo.added.single.title,
          'Basmati Rice is running low',
        );
      },
    );

    test(
      'titles an out-of-stock product differently from a merely low one',
      () async {
        final notificationRepo = FakeNotificationRepository();
        final container = _container(
          orders: [
            _orderWith('p1', id: 'o1'),
            _orderWith('p1', id: 'o2'),
          ],
          productRepo: FakeProductRepository([_product(id: 'p1', stock: 0)]),
          notificationRepo: notificationRepo,
        );
        addTearDown(container.dispose);

        container.read(stockAlertInitializerProvider);
        await _settle();

        expect(
          notificationRepo.added.single.title,
          'Basmati Rice is out of stock',
        );
      },
    );

    test('never fires for a product bought only once', () async {
      final notificationRepo = FakeNotificationRepository();
      final container = _container(
        orders: [_orderWith('p1', id: 'o1')],
        productRepo: FakeProductRepository([_product(id: 'p1', stock: 0)]),
        notificationRepo: notificationRepo,
      );
      addTearDown(container.dispose);

      container.read(stockAlertInitializerProvider);
      await _settle();

      expect(notificationRepo.added, isEmpty);
    });

    test(
      'does not repeat the same alert on a redundant re-emission of the same stock level',
      () async {
        final notificationRepo = FakeNotificationRepository();
        final productRepo = FakeProductRepository([
          _product(id: 'p1', stock: 3),
        ]);
        final container = _container(
          orders: [
            _orderWith('p1', id: 'o1'),
            _orderWith('p1', id: 'o2'),
          ],
          productRepo: productRepo,
          notificationRepo: notificationRepo,
        );
        addTearDown(container.dispose);

        container.read(stockAlertInitializerProvider);
        await _settle();
        expect(notificationRepo.added, hasLength(1));

        // Same product list re-emitted (e.g. an unrelated Firestore resync) —
        // still stock == 3, so this must not raise a second alert.
        productRepo.emit([_product(id: 'p1', stock: 3)]);
        await _settle();

        expect(notificationRepo.added, hasLength(1));
      },
    );
  });
}
