import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/data/models/user_model.dart';
import 'package:traders_retailer/data/repositories/auth_repository.dart';
import 'package:traders_retailer/data/repositories/auth_repository_provider.dart';
import 'package:traders_retailer/domain/entities/address_entity.dart';
import 'package:traders_retailer/domain/entities/bank_details_entity.dart';
import 'package:traders_retailer/domain/entities/business_hours_entity.dart';
import 'package:traders_retailer/domain/entities/notification_preferences_entity.dart';
import 'package:traders_retailer/features/auth/screens/pending_approval_screen.dart';

import '../helpers/test_viewport.dart';

/// Minimal enough to reach `PendingApproval` state — mirrors the fake in
/// `profile_screen_test.dart`.
class FakeAuthRepository implements AuthRepository {
  final UserModel user;
  bool signedOut = false;

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
  }) async =>
      user;

  @override
  Future<UserModel?> signIn({required String email, required String password}) async => user;

  @override
  Future<void> signOut() async => signedOut = true;

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
    AddressEntity? address,
    String? gstNumber,
    BankDetailsEntity? bankDetails,
    BusinessHoursEntity? businessHours,
    NotificationPreferencesEntity? notificationPreferences,
  }) async =>
      user;

  @override
  Future<void> updateFcmToken({required String uid, required String fcmToken}) async {}
}

final _retailer = UserModel(
  uid: 'u1',
  name: 'Ramesh',
  email: 'ramesh@test.com',
  phone: '9876543210',
  role: UserRole.customer,
  status: UserStatus.pending,
  businessName: 'Ramesh Kirana Store',
  createdAt: DateTime(2026, 1, 1),
);

void main() {
  useTallTestViewport();

  Widget wrap(FakeAuthRepository repository) => ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: PendingApprovalScreen()),
      );

  testWidgets('renders the support phone and email, both tappable', (tester) async {
    await tester.pumpWidget(wrap(FakeAuthRepository(_retailer)));
    await tester.pumpAndSettle();

    expect(find.textContaining('98604 60325'), findsOneWidget);
    expect(find.textContaining('vishvatejkatkar007@gmail.com'), findsWidgets);

    final callButton = tester.widget<OutlinedButton>(
      find.ancestor(of: find.textContaining('98604 60325'), matching: find.byType(OutlinedButton)),
    );
    final emailButton = tester.widget<OutlinedButton>(
      find.ancestor(of: find.textContaining('vishvatejkatkar007@gmail.com'), matching: find.byType(OutlinedButton)),
    );
    expect(callButton.onPressed, isNotNull);
    expect(emailButton.onPressed, isNotNull);
  });

  testWidgets('shows the pending verification message', (tester) async {
    await tester.pumpWidget(wrap(FakeAuthRepository(_retailer)));
    await tester.pumpAndSettle();

    expect(find.text('Account Verification Pending'), findsOneWidget);
  });

  testWidgets('signs out via the repository when "Sign Out" is tapped', (tester) async {
    final repository = FakeAuthRepository(_retailer);
    await tester.pumpWidget(wrap(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign Out & Try Another Account'));
    await tester.pumpAndSettle();

    expect(repository.signedOut, isTrue);
  });
}
