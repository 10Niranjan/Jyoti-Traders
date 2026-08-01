import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/core/theme/theme_controller.dart';
import 'package:traders_retailer/data/datasources/local_storage_service.dart';
import 'package:traders_retailer/data/models/user_model.dart';
import 'package:traders_retailer/data/repositories/auth_repository.dart';
import 'package:traders_retailer/data/repositories/auth_repository_provider.dart';
import 'package:traders_retailer/domain/entities/address_entity.dart';
import 'package:traders_retailer/domain/entities/bank_details_entity.dart';
import 'package:traders_retailer/domain/entities/business_hours_entity.dart';
import 'package:traders_retailer/domain/entities/notification_preferences_entity.dart';
import 'package:traders_retailer/features/admin/screens/admin_profile_screen.dart';

import '../helpers/test_viewport.dart';

class FakeAuthRepository implements AuthRepository {
  final UserModel user;
  Map<String, dynamic>? lastUpdate;
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
  }) async {
    lastUpdate = {'uid': uid, 'name': name, 'phone': phone, 'businessName': businessName};
    return user;
  }

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

final _admin = UserModel(
  uid: 'admin1',
  name: 'Admin Owner',
  email: 'admin@jyoti.com',
  phone: '9860460325',
  role: UserRole.admin,
  status: UserStatus.approved,
  businessName: 'Jyoti Kirana Administration',
  createdAt: DateTime(2026, 1, 1),
);

Widget _wrap(FakeAuthRepository repository) => ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(repository),
        themeModeProvider.overrideWith((ref) => ThemeModeController(FakeLocalStorageService())),
      ],
      child: const MaterialApp(home: AdminProfileScreen()),
    );

void main() {
  useTallTestViewport();

  testWidgets('shows the admin\'s name, email and phone, and an Appearance section', (tester) async {
    await tester.pumpWidget(_wrap(FakeAuthRepository(_admin)));
    await tester.pumpAndSettle();

    expect(find.text('Admin Owner'), findsOneWidget);
    expect(find.text('admin@jyoti.com'), findsOneWidget);
    expect(find.text('9860460325'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Log Out'), findsOneWidget);
  });

  testWidgets('edit sheet has no shop name field for admin', (tester) async {
    await tester.pumpWidget(_wrap(FakeAuthRepository(_admin)));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Phone Number'), findsOneWidget);
    expect(find.text('Business / Shop Name'), findsNothing);
  });

  testWidgets('editing name/phone saves without a shop name', (tester) async {
    final repo = FakeAuthRepository(_admin);
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Full Name'), 'New Admin Name');
    await tester.enterText(find.widgetWithText(TextFormField, 'Phone Number'), '9988776655');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Profile'), findsNothing);
    expect(repo.lastUpdate?['name'], 'New Admin Name');
    expect(repo.lastUpdate?['phone'], '9988776655');
    expect(repo.lastUpdate?['businessName'], isNull);
  });

  testWidgets('tapping Log Out shows the confirmation dialog', (tester) async {
    await tester.pumpWidget(_wrap(FakeAuthRepository(_admin)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Log Out'));
    await tester.pumpAndSettle();

    expect(find.text('Log out?'), findsOneWidget);
  });
}
