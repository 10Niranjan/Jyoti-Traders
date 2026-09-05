import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:traders_retailer/core/constants/route_names.dart';
import 'package:traders_retailer/data/repositories/repository_providers.dart';
import 'package:traders_retailer/domain/entities/address_entity.dart';
import 'package:traders_retailer/domain/entities/bank_details_entity.dart';
import 'package:traders_retailer/domain/entities/business_hours_entity.dart';
import 'package:traders_retailer/domain/entities/user_entity.dart';
import 'package:traders_retailer/domain/repositories/user_repository.dart';
import 'package:traders_retailer/features/admin/screens/retailer_detail_screen.dart';
import 'package:traders_retailer/features/admin/widgets/retailer_approval_card.dart';
import '../helpers/test_viewport.dart';

class FakeUserRepository implements UserRepository {
  @override
  Stream<List<UserEntity>> watchPendingUsers() => Stream.value([]);

  @override
  Future<List<UserEntity>> getApprovedUsers() async => [];

  @override
  Future<void> approveUser(String uid) async {}

  @override
  Future<void> rejectUser(String uid) async {}
}

final _fullUser = UserEntity(
  uid: 'r1',
  fullName: 'Owner One',
  shopName: 'Shop One',
  email: 'owner@shop.com',
  phone: '9876543210',
  role: UserRole.customer,
  status: UserStatus.pending,
  address: const AddressEntity(street: '12 MG Road', city: 'Pune', pincode: '411001'),
  gstNumber: '27ABCDE1234F1Z5',
  createdAt: DateTime(2026, 1, 15, 10, 30),
  bankDetails: const BankDetailsEntity(
    accountHolderName: 'Owner One',
    accountNumber: '1234567890',
    ifscCode: 'HDFC0001234',
    bankName: 'HDFC Bank',
    upiId: 'owner@upi',
  ),
  businessHours: const BusinessHoursEntity(openTime: '09:00', closeTime: '21:00'),
);

void main() {
  useTallTestViewport();

  testWidgets('RetailerDetailScreen shows the full retailer profile', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [userRepositoryProvider.overrideWithValue(FakeUserRepository())],
        child: MaterialApp(home: RetailerDetailScreen(user: _fullUser)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('owner@shop.com'), findsOneWidget);
    expect(find.text('27ABCDE1234F1Z5'), findsOneWidget);
    expect(find.text('09:00 – 21:00'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('HDFC Bank'), 200);
    expect(find.text('HDFC Bank'), findsOneWidget);
    expect(find.text('owner@upi'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Approve'), 200);
    expect(find.text('15 Jan 2026, 10:30 AM'), findsOneWidget);
    expect(find.text('Approve'), findsOneWidget); // pending retailer still actionable from here
  });

  testWidgets('tapping a queued retailer card opens its full detail screen', (tester) async {
    final router = GoRouter(
      initialLocation: RouteNames.adminApprovalQueue,
      routes: [
        GoRoute(
          path: RouteNames.adminApprovalQueue,
          builder: (context, state) => Scaffold(body: RetailerApprovalCard(user: _fullUser)),
        ),
        GoRoute(
          path: RouteNames.adminRetailerDetail,
          builder: (context, state) => RetailerDetailScreen(user: state.extra as UserEntity),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [userRepositoryProvider.overrideWithValue(FakeUserRepository())],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    // Tap the card's header (not the Approve/Reject buttons) to open details.
    await tester.tap(find.text('Shop One'));
    await tester.pumpAndSettle();

    expect(find.text('owner@shop.com'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('HDFC Bank'), 200);
    expect(find.text('HDFC Bank'), findsOneWidget);
  });
}
