import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/data/repositories/repository_providers.dart';
import 'package:traders_retailer/domain/entities/order_entity.dart';
import 'package:traders_retailer/domain/entities/user_entity.dart';
import 'package:traders_retailer/domain/repositories/order_repository.dart';
import 'package:traders_retailer/domain/repositories/user_repository.dart';
import 'package:traders_retailer/features/admin/screens/retailers_screen.dart';

class FakeUserRepository implements UserRepository {
  final List<UserEntity> pending;
  final List<UserEntity> approved;
  FakeUserRepository({this.pending = const [], this.approved = const []});

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
  @override
  Stream<List<OrderEntity>> watchAllOrders() => Stream.value(const []);

  @override
  Future<void> placeOrder(OrderEntity order) async {}

  @override
  Stream<List<OrderEntity>> watchOrderHistory(String userId) =>
      Stream.value(const []);

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

UserEntity _approved(String uid, String shopName) => UserEntity(
  uid: uid,
  fullName: 'Owner $uid',
  shopName: shopName,
  email: '$uid@test.com',
  phone: '9876543210',
  role: UserRole.customer,
  status: UserStatus.approved,
  createdAt: DateTime.now(),
);

UserEntity _pending(String uid, String shopName) => UserEntity(
  uid: uid,
  fullName: 'Owner $uid',
  shopName: shopName,
  email: '$uid@test.com',
  phone: '9876543210',
  role: UserRole.customer,
  status: UserStatus.pending,
  createdAt: DateTime.now(),
);

Widget _wrap(FakeUserRepository userRepo) => ProviderScope(
  overrides: [
    userRepositoryProvider.overrideWithValue(userRepo),
    orderRepositoryProvider.overrideWithValue(FakeOrderRepository()),
  ],
  child: const MaterialApp(home: RetailersScreen()),
);

void main() {
  testWidgets('opens on the Approved segment', (tester) async {
    await tester.pumpWidget(
      _wrap(FakeUserRepository(approved: [_approved('u1', 'Shop A')])),
    );
    await tester.pumpAndSettle();

    expect(find.text('Shop A'), findsOneWidget);
  });

  testWidgets(
    'switching to the Pending tab shows the approval queue with a live count badge',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          FakeUserRepository(
            approved: [_approved('u1', 'Shop A')],
            pending: [_pending('u2', 'Shop B')],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pending (1)'), findsOneWidget);

      await tester.tap(find.text('Pending (1)'));
      await tester.pumpAndSettle();

      expect(find.text('Shop B'), findsOneWidget);
      expect(find.text('Approve'), findsOneWidget);
      expect(find.text('Reject'), findsOneWidget);
    },
  );

  testWidgets('the Pending tab has no count suffix when the queue is empty', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(FakeUserRepository()));
    await tester.pumpAndSettle();

    expect(find.text('Pending'), findsOneWidget);
    expect(find.textContaining('Pending ('), findsNothing);
  });
}
