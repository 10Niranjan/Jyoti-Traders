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
import 'package:traders_retailer/features/admin/screens/retailer_list_screen.dart';

class FakeUserRepository implements UserRepository {
  final List<UserEntity> approved;
  FakeUserRepository(this.approved);

  @override
  Stream<List<UserEntity>> watchPendingUsers() => const Stream.empty();

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

UserEntity _user(String uid, String shopName) => UserEntity(
      uid: uid,
      fullName: 'Owner $uid',
      shopName: shopName,
      email: '$uid@test.com',
      phone: '9876543210',
      role: UserRole.customer,
      status: UserStatus.approved,
      createdAt: DateTime.now(),
    );

OrderEntity _order({required String id, required String userId, required String shopName, required double subtotal}) =>
    OrderEntity(
      id: id,
      userId: userId,
      shopName: shopName,
      items: [OrderItemEntity(productId: 'p1', name: 'Item', qty: 1, unitPrice: Money(subtotal))],
      subtotal: Money(subtotal),
      deliveryCharge: Money(0),
      paymentMethod: PaymentMethod.cod,
      paymentStatus: PaymentStatus.pending,
      orderStatus: OrderStatus.delivered,
      deliveryAddress: const AddressEntity(street: 'St', city: 'City', pincode: '123456'),
      createdAt: DateTime(2026, 7, 20),
    );

Widget _wrap(FakeUserRepository userRepo, FakeOrderRepository orderRepo) => ProviderScope(
      overrides: [
        userRepositoryProvider.overrideWithValue(userRepo),
        orderRepositoryProvider.overrideWithValue(orderRepo),
      ],
      child: const MaterialApp(home: RetailerListScreen()),
    );

void main() {
  testWidgets('shows an empty state when there are no approved retailers', (tester) async {
    await tester.pumpWidget(_wrap(FakeUserRepository([]), FakeOrderRepository([])));
    await tester.pumpAndSettle();

    expect(find.text('No approved retailers yet'), findsOneWidget);
  });

  testWidgets('shows every approved retailer even with zero orders', (tester) async {
    await tester.pumpWidget(_wrap(
      FakeUserRepository([_user('u1', 'Shop A')]),
      FakeOrderRepository([]),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Shop A'), findsOneWidget);
    expect(find.text('0 orders'), findsOneWidget);
    expect(find.text('₹0'), findsOneWidget);
  });

  testWidgets('computes total spend and order count per retailer, sorted by spend', (tester) async {
    await tester.pumpWidget(_wrap(
      FakeUserRepository([_user('u1', 'Small Spender'), _user('u2', 'Big Spender')]),
      FakeOrderRepository([
        _order(id: 'o1', userId: 'u1', shopName: 'Small Spender', subtotal: 1000),
        _order(id: 'o2', userId: 'u2', shopName: 'Big Spender', subtotal: 5000),
        _order(id: 'o3', userId: 'u2', shopName: 'Big Spender', subtotal: 5000),
      ]),
    ));
    await tester.pumpAndSettle();

    expect(find.text('₹1,000'), findsOneWidget);
    expect(find.text('1 order'), findsOneWidget);
    expect(find.text('₹10,000'), findsOneWidget);
    expect(find.text('2 orders'), findsOneWidget);

    // Sorted by total spend, highest first.
    final bigSpenderTop = tester.getTopLeft(find.text('Big Spender'));
    final smallSpenderTop = tester.getTopLeft(find.text('Small Spender'));
    expect(bigSpenderTop.dy, lessThan(smallSpenderTop.dy));
  });
}
