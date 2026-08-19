import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/data/repositories/repository_providers.dart';
import 'package:traders_retailer/domain/entities/address_entity.dart';
import 'package:traders_retailer/domain/entities/order_entity.dart';
import 'package:traders_retailer/domain/entities/order_item_entity.dart';
import 'package:traders_retailer/domain/entities/user_entity.dart';
import 'package:traders_retailer/domain/repositories/order_repository.dart';
import 'package:traders_retailer/domain/repositories/user_repository.dart';
import 'package:traders_retailer/domain/value_objects/money.dart';
import 'package:traders_retailer/features/admin/screens/all_orders_screen.dart';

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

class FakeUserRepository implements UserRepository {
  final List<UserEntity> approved;
  FakeUserRepository([this.approved = const []]);

  @override
  Stream<List<UserEntity>> watchPendingUsers() => const Stream.empty();

  @override
  Future<List<UserEntity>> getApprovedUsers() async => approved;

  @override
  Future<void> approveUser(String uid) async {}

  @override
  Future<void> rejectUser(String uid) async {}
}

OrderEntity _order({
  required String id,
  required String shopName,
  String userId = 'u1',
  OrderStatus status = OrderStatus.pending,
}) => OrderEntity(
  id: id,
  userId: userId,
  shopName: shopName,
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

Widget _wrap(FakeOrderRepository repo) => ProviderScope(
  overrides: [orderRepositoryProvider.overrideWithValue(repo)],
  child: const MaterialApp(home: AllOrdersScreen()),
);

Widget _wrapScoped(
  FakeOrderRepository orderRepo,
  FakeUserRepository userRepo,
  String retailerId,
) => ProviderScope(
  overrides: [
    orderRepositoryProvider.overrideWithValue(orderRepo),
    userRepositoryProvider.overrideWithValue(userRepo),
  ],
  child: MaterialApp(home: AllOrdersScreen(retailerId: retailerId)),
);

void main() {
  testWidgets('shows an empty state when there are no orders', (tester) async {
    await tester.pumpWidget(_wrap(FakeOrderRepository([])));
    await tester.pumpAndSettle();

    expect(find.text('No orders yet'), findsOneWidget);
  });

  testWidgets('lists every order with shop name and status by default', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        FakeOrderRepository([
          _order(id: 'o1', shopName: 'Shop A', status: OrderStatus.pending),
          _order(id: 'o2', shopName: 'Shop B', status: OrderStatus.delivered),
        ]),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Shop A'), findsOneWidget);
    expect(find.text('Shop B'), findsOneWidget);
  });

  testWidgets('filtering by status hides orders in other statuses', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        FakeOrderRepository([
          _order(id: 'o1', shopName: 'Shop A', status: OrderStatus.pending),
          _order(id: 'o2', shopName: 'Shop B', status: OrderStatus.delivered),
        ]),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilterChip, 'Delivered'));
    await tester.pumpAndSettle();

    expect(find.text('Shop A'), findsNothing);
    expect(find.text('Shop B'), findsOneWidget);
  });

  testWidgets(
    'shows a status-specific empty message when a filter matches nothing',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          FakeOrderRepository([
            _order(id: 'o1', shopName: 'Shop A', status: OrderStatus.pending),
          ]),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilterChip, 'Delivered'));
      await tester.pumpAndSettle();

      expect(find.text('No delivered orders'), findsOneWidget);
    },
  );

  testWidgets(
    'scoped to a retailer, only that retailer\'s orders show and the shop name is the title',
    (tester) async {
      final user = UserEntity(
        uid: 'u1',
        fullName: 'Owner u1',
        shopName: 'Shop A',
        email: 'u1@test.com',
        phone: '9876543210',
        role: UserRole.customer,
        status: UserStatus.approved,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        _wrapScoped(
          FakeOrderRepository([
            _order(id: 'o1', shopName: 'Shop A', userId: 'u1'),
            _order(id: 'o2', shopName: 'Shop B', userId: 'u2'),
          ]),
          FakeUserRepository([user]),
          'u1',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Shop A — Orders'), findsOneWidget); // app bar title
      expect(find.text('Order #${'o1'.toUpperCase()}'), findsOneWidget);
      expect(find.text('Order #${'o2'.toUpperCase()}'), findsNothing);
      // The per-row shop name is redundant once already scoped to one retailer.
      expect(find.text('Shop A'), findsNothing);
    },
  );

  testWidgets(
    'exporting with no orders shows a snackbar instead of opening the share sheet',
    (tester) async {
      await tester.pumpWidget(_wrap(FakeOrderRepository([])));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.ios_share_rounded));
      await tester.pumpAndSettle();

      expect(find.text('No orders to export.'), findsOneWidget);
    },
  );

  testWidgets(
    'exporting with orders attempts the share sheet without crashing',
    (tester) async {
      // No real platform binding in a widget test — the share call is wrapped
      // defensively (same pattern as every other platform-plugin call in this
      // codebase) and degrades to a debug print, so this confirms the export
      // button is wired up and the screen survives the round-trip either way.
      await tester.pumpWidget(
        _wrap(FakeOrderRepository([_order(id: 'o1', shopName: 'Shop A')])),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.ios_share_rounded));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    },
  );
}
