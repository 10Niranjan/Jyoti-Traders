import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/core/theme/app_theme.dart';
import 'package:traders_retailer/data/datasources/local_storage_service.dart';
import 'package:traders_retailer/data/models/user_model.dart';
import 'package:traders_retailer/data/repositories/auth_repository.dart';
import 'package:traders_retailer/data/repositories/auth_repository_provider.dart';
import 'package:traders_retailer/data/repositories/repository_providers.dart';
import 'package:traders_retailer/domain/entities/address_entity.dart';
import 'package:traders_retailer/domain/entities/bank_details_entity.dart';
import 'package:traders_retailer/domain/entities/business_hours_entity.dart';
import 'package:traders_retailer/domain/entities/category_entity.dart';
import 'package:traders_retailer/domain/entities/notification_entity.dart';
import 'package:traders_retailer/domain/entities/notification_preferences_entity.dart';
import 'package:traders_retailer/domain/entities/order_entity.dart';
import 'package:traders_retailer/domain/entities/order_item_entity.dart';
import 'package:traders_retailer/domain/entities/product_entity.dart';
import 'package:traders_retailer/domain/repositories/category_repository.dart';
import 'package:traders_retailer/domain/repositories/notification_repository.dart';
import 'package:traders_retailer/domain/repositories/order_repository.dart';
import 'package:traders_retailer/domain/repositories/product_repository.dart';
import 'package:traders_retailer/domain/value_objects/money.dart';
import 'package:traders_retailer/features/home/screens/home_screen.dart';
import 'package:traders_retailer/l10n/app_localizations.dart';

import '../helpers/fake_cart_repository.dart';

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
  Future<void> deleteAccount({required String uid, String? password}) async {}

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
  final List<ProductEntity> products;
  FakeProductRepository(this.products);

  @override
  Stream<List<ProductEntity>> watchProducts({String? categoryId}) =>
      Stream.value(products);

  @override
  Stream<List<ProductEntity>> watchAllProducts() => Stream.value(products);

  @override
  Future<List<ProductEntity>> searchProducts(String query) async => products
      .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
      .toList();

  @override
  Future<ProductEntity?> getProductById(String productId) async => null;

  @override
  Future<void> createProduct(ProductEntity product) async {}

  @override
  Future<void> updateProduct(ProductEntity product) async {}

  @override
  Future<void> deleteProduct(String productId) async {}
}

class FakeCategoryRepository implements CategoryRepository {
  final List<CategoryEntity> categories;
  FakeCategoryRepository([this.categories = const []]);

  @override
  Stream<List<CategoryEntity>> watchCategories() => Stream.value(categories);

  @override
  Future<void> createCategory(CategoryEntity category) async {}

  @override
  Future<void> updateCategory(CategoryEntity category) async {}

  @override
  Future<void> deleteCategory(String categoryId) async {}
}

class FakeLocalStorageService extends LocalStorageService {
  @override
  Set<String> getSeenFirstRunHints() => const {};

  @override
  Future<void> markFirstRunHintSeen(String hintId) async {}

  // Home now owns the search controller, which reads/writes recent searches.
  @override
  List<String> getRecentSearches() => const [];

  @override
  Future<void> addRecentSearch(String query) async {}
}

class FakeNotificationRepository implements NotificationRepository {
  @override
  Stream<List<NotificationEntity>> watchNotifications() =>
      Stream.value(const []);

  @override
  Future<void> addNotification(NotificationEntity notification) async {}

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

OrderEntity _orderWith(
  String productId, {
  required String id,
  OrderStatus status = OrderStatus.delivered,
  DateTime? createdAt,
}) => OrderEntity(
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
  orderStatus: status,
  deliveryAddress: const AddressEntity(
    street: 'St',
    city: 'City',
    pincode: '123456',
  ),
  createdAt: createdAt ?? DateTime(2026, 7, 20),
);

ProductEntity _product({
  required String id,
  required int stock,
  bool isTopProduct = false,
}) => ProductEntity(
  id: id,
  name: 'Basmati Rice',
  categoryId: 'c1',
  imageUrl: '',
  price: Money(1500),
  unit: ProductUnit.box,
  stock: stock,
  isActive: true,
  isTopProduct: isTopProduct,
);

Widget _wrap({
  required List<OrderEntity> orders,
  required List<ProductEntity> products,
  List<CategoryEntity> categories = const [],
  ThemeData? theme,
}) => ProviderScope(
  overrides: [
    authRepositoryProvider.overrideWithValue(FakeAuthRepository(_retailer)),
    orderRepositoryProvider.overrideWithValue(FakeOrderRepository(orders)),
    productRepositoryProvider.overrideWithValue(
      FakeProductRepository(products),
    ),
    categoryRepositoryProvider.overrideWithValue(
      FakeCategoryRepository(categories),
    ),
    notificationRepositoryProvider.overrideWithValue(
      FakeNotificationRepository(),
    ),
    cartRepositoryProvider.overrideWithValue(FakeCartRepository()),
    localStorageProvider.overrideWithValue(FakeLocalStorageService()),
  ],
  child: MaterialApp(
    theme: theme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const HomeScreen(),
  ),
);

void main() {
  testWidgets('shows a Buy Again rail for a product ordered twice or more', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        orders: [
          _orderWith('p1', id: 'o1'),
          _orderWith('p1', id: 'o2'),
        ],
        products: [_product(id: 'p1', stock: 20)],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Buy Again'), findsOneWidget);
    expect(find.text('Basmati Rice'), findsOneWidget);
  });

  testWidgets(
    'hides the Buy Again rail for a retailer with no repeat orders yet',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          orders: [_orderWith('p1', id: 'o1')],
          products: [_product(id: 'p1', stock: 20)],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Buy Again'), findsNothing);
    },
  );

  testWidgets('shows the low-stock banner when a regular is running low', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        orders: [
          _orderWith('p1', id: 'o1'),
          _orderWith('p1', id: 'o2'),
        ],
        products: [_product(id: 'p1', stock: 3)],
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('1 of your regulars is low or out of stock.'),
      findsOneWidget,
    );
  });

  testWidgets('hides the low-stock banner when regulars are well stocked', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        orders: [
          _orderWith('p1', id: 'o1'),
          _orderWith('p1', id: 'o2'),
        ],
        products: [_product(id: 'p1', stock: 40)],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('low or out of stock'), findsNothing);
  });

  testWidgets('shows a Top Products section for admin-marked products', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        orders: const [],
        products: [_product(id: 'p1', stock: 20, isTopProduct: true)],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Top Products'), findsOneWidget);
    expect(find.text('Basmati Rice'), findsOneWidget);
  });

  testWidgets('hides the Top Products section when nothing is marked as top', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        orders: const [],
        products: [_product(id: 'p1', stock: 20, isTopProduct: false)],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Top Products'), findsNothing);
  });

  testWidgets('still shows the category grid beneath the new sections', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        orders: const [],
        products: const [],
        categories: [
          const CategoryEntity(
            id: 'c1',
            name: 'Grains',
            iconUrl: '',
            displayOrder: 0,
            isActive: true,
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Grains'), findsOneWidget);
  });

  // Regression: the header's logout icon signed the retailer out on a single
  // stray tap, with no confirmation (Settings already asked first).
  testWidgets('tapping the header logout icon asks before signing out', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(orders: const [], products: const []));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.logout_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Log out?'), findsOneWidget);
    // Cancelling leaves the retailer on Home.
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Log out?'), findsNothing);
    expect(find.byIcon(Icons.logout_rounded), findsOneWidget);
  });

  testWidgets('shows a search bar for searching without switching tabs', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(orders: const [], products: const []));
    await tester.pumpAndSettle();

    expect(find.text('Search products...'), findsOneWidget);
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);
  });

  testWidgets(
    'search icon sits inside the one text field, even under the app theme',
    (tester) async {
      // Regression: the theme's filled/enabledBorder used to paint a second
      // box inside the pill, leaving the icon outside it.
      await tester.pumpWidget(
        _wrap(orders: const [], products: const [], theme: AppTheme.lightTheme),
      );
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(TextField),
          matching: find.byIcon(Icons.search_rounded),
        ),
        findsOneWidget,
      );
      expect(find.byType(InputDecorator), findsOneWidget);
    },
  );

  testWidgets('typing in the Home search bar shows results in place', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        orders: const [],
        products: [_product(id: 'p1', stock: 20)],
        categories: const [
          CategoryEntity(
            id: 'c1',
            name: 'Grains',
            iconUrl: '',
            displayOrder: 0,
            isActive: true,
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Browse Categories'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'rice');
    await tester.pump(const Duration(milliseconds: 500)); // search debounce
    await tester.pumpAndSettle();

    expect(find.text('Basmati Rice'), findsOneWidget);
    expect(find.text('Browse Categories'), findsNothing);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Browse Categories'), findsOneWidget);
  });

  testWidgets('shows a live strip for the newest in-progress order', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        orders: [
          _orderWith(
            'p1',
            id: 'older-order-id',
            status: OrderStatus.confirmed,
            createdAt: DateTime(2026, 7, 21),
          ),
          _orderWith(
            'p1',
            id: 'newest-order-id',
            status: OrderStatus.outForDelivery,
            createdAt: DateTime(2026, 7, 22),
          ),
        ],
        products: const [],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Order #NEWEST-O is out for delivery'), findsOneWidget);
    expect(find.textContaining('Order #OLDER-OR'), findsNothing);
    expect(find.text('Track'), findsOneWidget);
  });

  testWidgets('no live strip when every order is delivered or cancelled', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        orders: [
          _orderWith('p1', id: 'delivered-order'),
          _orderWith(
            'p1',
            id: 'cancelled-order',
            status: OrderStatus.cancelled,
            createdAt: DateTime(2026, 7, 25),
          ),
        ],
        products: const [],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Track'), findsNothing);
  });

  testWidgets('a search with no matches says so instead of going blank', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        orders: const [],
        products: [_product(id: 'p1', stock: 20)],
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('No products found for "zzz"'), findsOneWidget);
  });
}
