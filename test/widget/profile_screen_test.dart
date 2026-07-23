import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/core/theme/theme_controller.dart';
import 'package:traders_retailer/data/datasources/local_storage_service.dart';
import 'package:traders_retailer/data/models/user_model.dart';
import 'package:traders_retailer/data/repositories/auth_repository.dart';
import 'package:traders_retailer/data/repositories/auth_repository_provider.dart';
import 'package:traders_retailer/domain/entities/address_entity.dart';
import 'package:traders_retailer/features/profile/screens/profile_screen.dart';

import '../helpers/test_viewport.dart';

/// Minimal enough to reach `AuthenticatedCustomer` — mirrors the fake in
/// `upi_payment_screen_test.dart`, which introduced this pattern first.
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
  }) async =>
      user;

  @override
  Future<UserModel?> signIn({required String email, required String password}) async => user;

  @override
  Future<void> signOut() async {}

  @override
  Future<UserModel?> getCurrentUser() async => user;

  @override
  Future<UserModel?> refreshUserStatus(String uid) async => user;

  @override
  Future<UserModel?> updateProfile({required String uid, AddressEntity? address, String? gstNumber}) async => user;

  @override
  Future<void> updateFcmToken({required String uid, required String fcmToken}) async {}
}

class FakeLocalStorageService extends LocalStorageService {
  bool? stored;
  FakeLocalStorageService([this.stored]);

  @override
  bool? getThemePreference() => stored;

  @override
  Future<void> saveThemePreference(bool isDarkMode) async => stored = isDarkMode;

  @override
  Future<void> clearThemePreference() async => stored = null;
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

Widget _wrap({ThemeMode initial = ThemeMode.system}) => ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(FakeAuthRepository(_retailer)),
        themeModeProvider.overrideWith((ref) => ThemeModeController(FakeLocalStorageService(
              initial == ThemeMode.system ? null : initial == ThemeMode.dark,
            ))),
      ],
      child: const MaterialApp(home: ProfileScreen()),
    );

void main() {
  useTallTestViewport();

  testWidgets('shows an Appearance section with System/Light/Dark segments', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
  });

  testWidgets('tapping Dark switches the app theme mode', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    final segmentedButton = tester.widget<SegmentedButton<ThemeMode>>(find.byType(SegmentedButton<ThemeMode>));
    expect(segmentedButton.selected, {ThemeMode.dark});
  });
}
