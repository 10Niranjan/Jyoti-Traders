import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/data/repositories/repository_providers.dart';
import 'package:traders_retailer/domain/entities/address_entity.dart';
import 'package:traders_retailer/domain/entities/user_entity.dart';
import 'package:traders_retailer/domain/repositories/user_repository.dart';
import 'package:traders_retailer/features/admin/screens/approval_queue_screen.dart';

class FakeUserRepository implements UserRepository {
  final List<UserEntity> pending;
  final List<String> approvedCalls = [];
  final List<String> rejectedCalls = [];
  Completer<void>? approveGate;

  FakeUserRepository(this.pending);

  @override
  Stream<List<UserEntity>> watchPendingUsers() => Stream.value(pending);

  @override
  Future<List<UserEntity>> getApprovedUsers() async => [];

  @override
  Future<void> approveUser(String uid) async {
    approvedCalls.add(uid);
    if (approveGate != null) await approveGate!.future;
  }

  @override
  Future<void> rejectUser(String uid) async {
    rejectedCalls.add(uid);
  }
}

UserEntity _pendingUser(String uid) => UserEntity(
      uid: uid,
      fullName: 'Owner $uid',
      shopName: 'Shop $uid',
      email: '$uid@test.com',
      phone: '9876543210',
      role: UserRole.customer,
      status: UserStatus.pending,
      address: const AddressEntity(street: '12 MG Road', city: 'Pune', pincode: '411001'),
      createdAt: DateTime.now(),
    );

void main() {
  testWidgets('shows empty state when there are no pending retailers', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [userRepositoryProvider.overrideWithValue(FakeUserRepository([]))],
        child: const MaterialApp(home: ApprovalQueueScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Approval queue is clear!'), findsOneWidget);
  });

  testWidgets('renders shop name, owner, phone and address for each pending retailer', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [userRepositoryProvider.overrideWithValue(FakeUserRepository([_pendingUser('r1')]))],
        child: const MaterialApp(home: ApprovalQueueScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Shop r1'), findsOneWidget);
    expect(find.text('Owner: Owner r1'), findsOneWidget);
    expect(find.text('Phone: 9876543210'), findsOneWidget);
    expect(find.text('12 MG Road, Pune - 411001'), findsOneWidget);
  });

  testWidgets('shows a fallback when a retailer has no address yet', (tester) async {
    final userWithoutAddress = UserEntity(
      uid: 'r2',
      fullName: 'Owner r2',
      shopName: 'Shop r2',
      email: 'r2@test.com',
      phone: '9876543211',
      role: UserRole.customer,
      status: UserStatus.pending,
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [userRepositoryProvider.overrideWithValue(FakeUserRepository([userWithoutAddress]))],
        child: const MaterialApp(home: ApprovalQueueScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Address not provided yet'), findsOneWidget);
  });

  testWidgets('tapping Approve calls the repository, shows a spinner mid-flight, then a success snackbar', (tester) async {
    final repo = FakeUserRepository([_pendingUser('r1')]);
    repo.approveGate = Completer<void>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [userRepositoryProvider.overrideWithValue(repo)],
        child: const MaterialApp(home: ApprovalQueueScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Approve'));
    await tester.pump(); // start the async call, don't settle — the gate is still closed

    expect(repo.approvedCalls, ['r1']);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Approve'), findsNothing); // buttons swapped for the spinner while busy

    repo.approveGate!.complete();
    await tester.pumpAndSettle();

    expect(find.text('Shop r1 approved successfully!'), findsOneWidget);
  });

  testWidgets('tapping Reject calls the repository and shows a confirmation snackbar', (tester) async {
    final repo = FakeUserRepository([_pendingUser('r1')]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [userRepositoryProvider.overrideWithValue(repo)],
        child: const MaterialApp(home: ApprovalQueueScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reject'));
    await tester.pumpAndSettle();

    expect(repo.rejectedCalls, ['r1']);
    expect(find.text('Shop r1 rejected.'), findsOneWidget);
  });
}
