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
import 'package:traders_retailer/features/auth/screens/auth_screen.dart';

import '../helpers/test_viewport.dart';

/// Enough of [AuthRepository] to keep `AuthController` out of its loading
/// state — none of these calls are exercised by these tests.
class FakeAuthRepository implements AuthRepository {
  @override
  Stream<UserModel?> get authStateChanges => Stream.value(null);

  @override
  Future<UserModel?> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
    required UserRole role,
    required String businessName,
  }) async => null;

  @override
  Future<UserModel?> signIn({required String email, required String password}) async => null;

  @override
  Future<void> signOut() async {}

  @override
  Future<UserModel?> getCurrentUser() async => null;

  @override
  Future<UserModel?> refreshUserStatus(String uid) async => null;

  @override
  Future<UserModel?> updateProfile({
    required String uid,
    String? name,
    String? phone,
    String? businessName,
    String? photoUrl,
    AddressEntity? address,
    String? gstNumber,
    BankDetailsEntity? bankDetails,
    BusinessHoursEntity? businessHours,
    NotificationPreferencesEntity? notificationPreferences,
  }) async => null;

  @override
  Future<void> updateFcmToken({required String uid, required String fcmToken}) async {}

  @override
  Future<void> sendPasswordResetEmail(String email) async {}
}

void main() {
  useTallTestViewport();

  Future<void> pumpSignUp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(FakeAuthRepository())],
        child: const MaterialApp(home: AuthScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();
  }

  testWidgets('sign up screen shows no validation errors on first load', (tester) async {
    await pumpSignUp(tester);

    expect(find.text('Name is required'), findsNothing);
    expect(find.text('Phone number is required'), findsNothing);
    expect(find.text('Shop name is required'), findsNothing);
    expect(find.text('Email is required'), findsNothing);
    expect(find.text('Password is required'), findsNothing);
  });

  testWidgets('typing in one field does not flag the other untouched fields', (tester) async {
    await pumpSignUp(tester);

    await tester.enterText(find.widgetWithText(TextFormField, 'Full Name'), 'A');
    await tester.pump();

    // The touched field validates live...
    expect(find.text('Name must be at least 2 characters'), findsOneWidget);
    // ...but fields the user hasn't touched yet stay quiet.
    expect(find.text('Phone number is required'), findsNothing);
    expect(find.text('Shop name is required'), findsNothing);
    expect(find.text('Email is required'), findsNothing);
    expect(find.text('Password is required'), findsNothing);
  });

  testWidgets('submitting with empty fields flags all of them', (tester) async {
    await pumpSignUp(tester);

    await tester.tap(find.text('Create Account'));
    await tester.pump();

    expect(find.text('Name is required'), findsOneWidget);
    expect(find.text('Phone number is required'), findsOneWidget);
    expect(find.text('Shop name is required'), findsOneWidget);
    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });
}
