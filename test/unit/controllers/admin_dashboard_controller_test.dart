import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/data/repositories/repository_providers.dart';
import 'package:traders_retailer/domain/entities/address_entity.dart';
import 'package:traders_retailer/domain/entities/category_entity.dart';
import 'package:traders_retailer/domain/entities/order_entity.dart';
import 'package:traders_retailer/domain/entities/order_item_entity.dart';
import 'package:traders_retailer/domain/entities/product_entity.dart';
import 'package:traders_retailer/domain/entities/user_entity.dart';
import 'package:traders_retailer/domain/repositories/category_repository.dart';
import 'package:traders_retailer/domain/repositories/order_repository.dart';
import 'package:traders_retailer/domain/repositories/product_repository.dart';
import 'package:traders_retailer/domain/repositories/user_repository.dart';
import 'package:traders_retailer/domain/value_objects/money.dart';
import 'package:traders_retailer/features/admin/controllers/admin_category_controller.dart';
import 'package:traders_retailer/features/admin/controllers/admin_dashboard_controller.dart';
import 'package:traders_retailer/features/admin/controllers/admin_product_controller.dart';

class FakeProductRepository implements ProductRepository {
  final List<ProductEntity> products;
  FakeProductRepository(this.products);

  @override
  Stream<List<ProductEntity>> watchProducts({String? categoryId}) =>
      Stream.value(products);

  @override
  Stream<List<ProductEntity>> watchAllProducts() => Stream.value(products);

  @override
  Future<List<ProductEntity>> searchProducts(String query) async => [];

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
  FakeCategoryRepository(this.categories);

  @override
  Stream<List<CategoryEntity>> watchCategories() => Stream.value(categories);

  @override
  Future<void> createCategory(CategoryEntity category) async {}

  @override
  Future<void> updateCategory(CategoryEntity category) async {}

  @override
  Future<void> deleteCategory(String categoryId) async {}
}

class FakeUserRepository implements UserRepository {
  final List<UserEntity> approved;
  FakeUserRepository(this.approved);

  @override
  Stream<List<UserEntity>> watchPendingUsers() => Stream.value(const []);

  @override
  Future<List<UserEntity>> getApprovedUsers() async => approved;

  @override
  Future<void> approveUser(String uid) async {}

  @override
  Future<void> rejectUser(String uid) async {}
}

ProductEntity _product(String id, String categoryId) => ProductEntity(
  id: id,
  name: id,
  categoryId: categoryId,
  imageUrl: '',
  price: Money(10),
  unit: ProductUnit.piece,
  stock: 10,
  isActive: true,
);

UserEntity _approvedUser(String uid, DateTime createdAt) => UserEntity(
  uid: uid,
  fullName: 'Owner $uid',
  shopName: 'Shop $uid',
  email: '$uid@test.com',
  phone: '9876543210',
  role: UserRole.customer,
  status: UserStatus.approved,
  createdAt: createdAt,
);

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

OrderEntity _order(
  String id,
  DateTime createdAt, {
  List<OrderItemEntity>? items,
  OrderStatus status = OrderStatus.pending,
  double subtotal = 3000,
  double deliveryCharge = 50,
}) => OrderEntity(
  id: id,
  userId: 'u1',
  shopName: 'Shop u1',
  items:
      items ??
      [
        OrderItemEntity(
          productId: 'p1',
          name: 'Item',
          qty: 1,
          unitPrice: Money(subtotal),
        ),
      ],
  subtotal: Money(subtotal),
  deliveryCharge: Money(deliveryCharge),
  paymentMethod: PaymentMethod.cod,
  paymentStatus: PaymentStatus.pending,
  orderStatus: status,
  deliveryAddress: const AddressEntity(
    street: 'St',
    city: 'City',
    pincode: '123456',
  ),
  createdAt: createdAt,
);

void main() {
  group('todayRevenueProvider', () {
    test('sums grandTotal for today\'s orders only', () async {
      final now = DateTime.now();
      final container = ProviderContainer(
        overrides: [
          orderRepositoryProvider.overrideWithValue(
            FakeOrderRepository([
              _order('today1', now, subtotal: 3000, deliveryCharge: 50),
              _order('today2', now, subtotal: 2000, deliveryCharge: 0),
              _order(
                'yesterday',
                now.subtract(const Duration(days: 1)),
                subtotal: 5000,
                deliveryCharge: 0,
              ),
            ]),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(allOrdersProvider.future);
      expect(container.read(todayRevenueProvider).value, 3050 + 2000);
    });

    test('excludes cancelled orders', () async {
      final now = DateTime.now();
      final container = ProviderContainer(
        overrides: [
          orderRepositoryProvider.overrideWithValue(
            FakeOrderRepository([
              _order(
                'cancelled',
                now,
                subtotal: 9999,
                status: OrderStatus.cancelled,
              ),
              _order('valid', now, subtotal: 100, deliveryCharge: 0),
            ]),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(allOrdersProvider.future);
      expect(container.read(todayRevenueProvider).value, 100);
    });
  });

  group('topProductsProvider', () {
    test('ranks products by total revenue, highest first', () async {
      final now = DateTime.now();
      final container = ProviderContainer(
        overrides: [
          orderRepositoryProvider.overrideWithValue(
            FakeOrderRepository([
              _order(
                'o1',
                now,
                items: [
                  OrderItemEntity(
                    productId: 'p1',
                    name: 'Rice',
                    qty: 1,
                    unitPrice: Money(100),
                  ),
                  OrderItemEntity(
                    productId: 'p2',
                    name: 'Sugar',
                    qty: 1,
                    unitPrice: Money(500),
                  ),
                ],
              ),
              _order(
                'o2',
                now,
                items: [
                  OrderItemEntity(
                    productId: 'p1',
                    name: 'Rice',
                    qty: 1,
                    unitPrice: Money(100),
                  ),
                ],
              ),
            ]),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(allOrdersProvider.future);
      final products = container.read(topProductsProvider).value!;
      expect(products.map((p) => p.name), ['Sugar', 'Rice']);
      expect(products.first.revenue, 500);
      expect(products.last.revenue, 200);
    });

    test('excludes cancelled orders from ranking', () async {
      final now = DateTime.now();
      final container = ProviderContainer(
        overrides: [
          orderRepositoryProvider.overrideWithValue(
            FakeOrderRepository([
              _order(
                'cancelled',
                now,
                status: OrderStatus.cancelled,
                items: [
                  OrderItemEntity(
                    productId: 'p1',
                    name: 'Rice',
                    qty: 1,
                    unitPrice: Money(9999),
                  ),
                ],
              ),
            ]),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(allOrdersProvider.future);
      expect(container.read(topProductsProvider).value, isEmpty);
    });
  });

  group('categoryRevenueProvider', () {
    test(
      'attributes each line item\'s revenue to its product\'s category, highest first',
      () async {
        final now = DateTime.now();
        final container = ProviderContainer(
          overrides: [
            orderRepositoryProvider.overrideWithValue(
              FakeOrderRepository([
                _order(
                  'o1',
                  now,
                  items: [
                    OrderItemEntity(
                      productId: 'rice',
                      name: 'Rice',
                      qty: 1,
                      unitPrice: Money(100),
                    ),
                    OrderItemEntity(
                      productId: 'soap',
                      name: 'Soap',
                      qty: 1,
                      unitPrice: Money(500),
                    ),
                  ],
                ),
              ]),
            ),
            productRepositoryProvider.overrideWithValue(
              FakeProductRepository([
                _product('rice', 'grains'),
                _product('soap', 'staples'),
              ]),
            ),
            categoryRepositoryProvider.overrideWithValue(
              FakeCategoryRepository([
                const CategoryEntity(
                  id: 'grains',
                  name: 'Grains',
                  iconUrl: '',
                  displayOrder: 0,
                  isActive: true,
                ),
                const CategoryEntity(
                  id: 'staples',
                  name: 'Staples',
                  iconUrl: '',
                  displayOrder: 1,
                  isActive: true,
                ),
              ]),
            ),
          ],
        );
        addTearDown(container.dispose);

        await container.read(allOrdersProvider.future);
        await container.read(allProductsProvider.future);
        await container.read(adminCategoriesProvider.future);

        final categories = container.read(categoryRevenueProvider).value!;
        expect(categories.map((c) => c.categoryName), ['Staples', 'Grains']);
        expect(categories.first.revenue, 500);
      },
    );

    test(
      'skips line items whose product no longer exists in the catalog',
      () async {
        final now = DateTime.now();
        final container = ProviderContainer(
          overrides: [
            orderRepositoryProvider.overrideWithValue(
              FakeOrderRepository([
                _order(
                  'o1',
                  now,
                  items: [
                    OrderItemEntity(
                      productId: 'deleted',
                      name: 'Gone',
                      qty: 1,
                      unitPrice: Money(999),
                    ),
                  ],
                ),
              ]),
            ),
            productRepositoryProvider.overrideWithValue(
              FakeProductRepository(const []),
            ),
            categoryRepositoryProvider.overrideWithValue(
              FakeCategoryRepository(const []),
            ),
          ],
        );
        addTearDown(container.dispose);

        await container.read(allOrdersProvider.future);
        await container.read(allProductsProvider.future);
        await container.read(adminCategoriesProvider.future);

        expect(container.read(categoryRevenueProvider).value, isEmpty);
      },
    );
  });

  group('retailerGrowthProvider', () {
    test(
      'cumulative count only includes retailers approved by the end of each month',
      () async {
        final now = DateTime.now();
        final thisMonth = DateTime(now.year, now.month, 1);
        final twoMonthsAgo = DateTime(now.year, now.month - 2, 1);
        final container = ProviderContainer(
          overrides: [
            userRepositoryProvider.overrideWithValue(
              FakeUserRepository([
                _approvedUser('u1', twoMonthsAgo),
                _approvedUser('u2', thisMonth),
              ]),
            ),
          ],
        );
        addTearDown(container.dispose);

        await container.read(approvedUsersProvider.future);
        final months = container.read(retailerGrowthProvider).value!;

        expect(months.length, 6);
        expect(
          months.last.cumulativeCount,
          2,
        ); // both approved by the current month
        expect(
          months.first.cumulativeCount,
          0,
        ); // 5 months before now, neither had joined yet
      },
    );
  });

  group('orderStatusFunnelProvider', () {
    test(
      'each stage counts orders that reached at least that status, cancelled excluded',
      () async {
        final now = DateTime.now();
        final container = ProviderContainer(
          overrides: [
            orderRepositoryProvider.overrideWithValue(
              FakeOrderRepository([
                _order('pending', now, status: OrderStatus.pending),
                _order('confirmed', now, status: OrderStatus.confirmed),
                _order('delivered', now, status: OrderStatus.delivered),
                _order('cancelled', now, status: OrderStatus.cancelled),
              ]),
            ),
          ],
        );
        addTearDown(container.dispose);

        await container.read(allOrdersProvider.future);
        final stages = container.read(orderStatusFunnelProvider).value!;

        expect(stages.map((s) => s.status), [
          OrderStatus.pending,
          OrderStatus.confirmed,
          OrderStatus.outForDelivery,
          OrderStatus.delivered,
        ]);
        // pending/confirmed/delivered all reached "pending"; cancelled never counts.
        expect(stages[0].count, 3);
        // confirmed + delivered reached "confirmed".
        expect(stages[1].count, 2);
        expect(
          stages[2].count,
          1,
        ); // only "delivered" reached "out for delivery"
        expect(stages[3].count, 1); // only "delivered" reached "delivered"
      },
    );
  });
}
