import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/data/repositories/repository_providers.dart';
import 'package:traders_retailer/domain/entities/address_entity.dart';
import 'package:traders_retailer/domain/entities/notification_entity.dart';
import 'package:traders_retailer/domain/entities/order_entity.dart';
import 'package:traders_retailer/domain/entities/order_item_entity.dart';
import 'package:traders_retailer/domain/entities/user_entity.dart';
import 'package:traders_retailer/domain/repositories/notification_repository.dart';
import 'package:traders_retailer/domain/repositories/order_repository.dart';
import 'package:traders_retailer/domain/repositories/user_repository.dart';
import 'package:traders_retailer/domain/value_objects/money.dart';
import 'package:traders_retailer/features/admin/screens/admin_dashboard_screen.dart';

class FakeNotificationRepository implements NotificationRepository {
  @override
  Stream<List<NotificationEntity>> watchNotifications() => Stream.value(const []);

  @override
  Future<void> addNotification(NotificationEntity notification) async {}

  @override
  Future<void> markAsRead(String id) async {}

  @override
  Future<void> markAllAsRead() async {}
}

class FakeUserRepository implements UserRepository {
  final List<UserEntity> pending;
  final List<UserEntity> approved;
  FakeUserRepository({required this.pending, required this.approved});

  @override
  Stream<List<UserEntity>> watchPendingUsers() => Stream.value(pending);

  @override
  Future<List<UserEntity>> getApprovedUsers() async => approved;

  @override
  Future<void> approveUser(String uid) async {}

  @override
  Future<void> rejectUser(String uid) async {}
}

class FakeOrderRepository implements OrderRepository {
  final List<OrderEntity> orders;
  FakeOrderRepository(this.orders);

  @override
  Stream<List<OrderEntity>> watchAllOrders() => Stream.value(orders);

  @override
  Future<void> placeOrder(OrderEntity order) async {}

  @override
  Stream<List<OrderEntity>> watchOrderHistory(String userId) => Stream.value(orders);

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {}

  @override
  Future<void> recordPaymentClaim(String orderId, {String? screenshotUrl}) async {}

  @override
  Future<void> updatePaymentStatus(String orderId, PaymentStatus status) async {}
}

UserEntity _user(String uid, {UserStatus status = UserStatus.pending}) => UserEntity(
      uid: uid,
      fullName: 'Owner $uid',
      shopName: 'Shop $uid',
      email: '$uid@test.com',
      phone: '9876543210',
      role: UserRole.customer,
      status: status,
      createdAt: DateTime.now(),
    );

OrderEntity _order(String id, DateTime createdAt) => OrderEntity(
      id: id,
      userId: 'u1',
      shopName: 'Shop u1',
      items: [
        OrderItemEntity(productId: 'p1', name: 'Item', qty: 1, unitPrice: Money(10)),
      ],
      subtotal: Money(3000),
      deliveryCharge: Money(50),
      paymentMethod: PaymentMethod.cod,
      paymentStatus: PaymentStatus.pending,
      orderStatus: OrderStatus.pending,
      deliveryAddress: const AddressEntity(street: 'St', city: 'City', pincode: '123456'),
      createdAt: createdAt,
    );

void main() {
  testWidgets('AdminDashboardScreen renders real stat counts, chart and approval queue', (tester) async {
    final now = DateTime.now();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userRepositoryProvider.overrideWithValue(
            FakeUserRepository(
              pending: [_user('pending1')],
              approved: [_user('approved1', status: UserStatus.approved), _user('approved2', status: UserStatus.approved)],
            ),
          ),
          orderRepositoryProvider.overrideWithValue(
            FakeOrderRepository([
              _order('o1', now),
              _order('o2', now.subtract(const Duration(days: 2))),
            ]),
          ),
          notificationRepositoryProvider.overrideWithValue(FakeNotificationRepository()),
        ],
        child: const MaterialApp(home: AdminDashboardScreen()),
      ),
    );

    await tester.pumpAndSettle();

    // Stat cards show real derived counts, not the old hardcoded placeholders.
    expect(find.text('Pending Approvals'), findsOneWidget);
    expect(find.text('Total Retailers'), findsOneWidget);
    expect(find.text("Today's Orders"), findsOneWidget);
    expect(find.text('1'), findsWidgets); // pending count + today's order count
    expect(find.text('2'), findsOneWidget); // total retailers

    // Chart and approval queue rendered without throwing.
    expect(find.text('Orders — Last 7 Days'), findsOneWidget);
    expect(find.text('Retailer Approval Queue'), findsOneWidget);
    expect(find.text('Shop pending1'), findsOneWidget);
    expect(find.text('Approve'), findsOneWidget);
    expect(find.text('Reject'), findsOneWidget);
  });

  testWidgets('AdminDashboardScreen shows empty state when no pending users', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userRepositoryProvider.overrideWithValue(FakeUserRepository(pending: [], approved: [])),
          orderRepositoryProvider.overrideWithValue(FakeOrderRepository([])),
          notificationRepositoryProvider.overrideWithValue(FakeNotificationRepository()),
        ],
        child: const MaterialApp(home: AdminDashboardScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Approval queue is clear!'), findsOneWidget);
    expect(find.text('No orders yet this week'), findsOneWidget);
  });
}
