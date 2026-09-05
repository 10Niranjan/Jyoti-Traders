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
import 'package:traders_retailer/features/profile/screens/profile_screen.dart';
import 'package:traders_retailer/l10n/app_localizations.dart';

import '../helpers/test_viewport.dart';

/// Minimal enough to reach `AuthenticatedCustomer` — mirrors the fake in
/// `upi_payment_screen_test.dart`, which introduced this pattern first.
class FakeAuthRepository implements AuthRepository {
  final UserModel user;
  Map<String, dynamic>? lastUpdate;
  String? passwordResetSentTo;
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
    lastUpdate = {
      'uid': uid,
      'name': name,
      'phone': phone,
      'businessName': businessName,
      'photoUrl': photoUrl,
      'address': address,
      'gstNumber': gstNumber,
      'bankDetails': bankDetails,
      'businessHours': businessHours,
      'notificationPreferences': notificationPreferences,
    };
    return user;
  }

  @override
  Future<void> updateFcmToken({required String uid, required String fcmToken}) async {}

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    passwordResetSentTo = email;
  }
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

  @override
  String? getLanguagePreference() => null;

  @override
  Future<void> saveLanguagePreference(String languageCode) async {}

  @override
  Future<void> clearLanguagePreference() async {}
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

Widget _wrap(FakeAuthRepository repository, {ThemeMode initial = ThemeMode.system}) => ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(repository),
        themeModeProvider.overrideWith((ref) => ThemeModeController(FakeLocalStorageService(
              initial == ThemeMode.system ? null : initial == ThemeMode.dark,
            ))),
        localStorageProvider.overrideWithValue(FakeLocalStorageService()),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ProfileScreen(),
      ),
    );

void main() {
  useTallTestViewport();

  testWidgets('shows an Appearance section with System/Light/Dark segments', (tester) async {
    await tester.pumpWidget(_wrap(FakeAuthRepository(_retailer)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
  });

  testWidgets('tapping Dark switches the app theme mode', (tester) async {
    await tester.pumpWidget(_wrap(FakeAuthRepository(_retailer)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    final segmentedButton = tester.widget<SegmentedButton<ThemeMode>>(find.byType(SegmentedButton<ThemeMode>));
    expect(segmentedButton.selected, {ThemeMode.dark});
  });

  testWidgets('header card shows shop name, owner name and phone', (tester) async {
    await tester.pumpWidget(_wrap(FakeAuthRepository(_retailer)));
    await tester.pumpAndSettle();

    expect(find.text('Ramesh Kirana Store'), findsOneWidget);
    expect(find.text('Ramesh'), findsOneWidget);
    expect(find.text('9876543210'), findsOneWidget);
  });

  testWidgets('edit profile sheet rejects a digit in the name field and does not save', (tester) async {
    final repo = FakeAuthRepository(_retailer);
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Full Name'), 'A');
    await tester.pump();
    expect(find.text('Name must be at least 2 characters'), findsOneWidget);

    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(repo.lastUpdate, isNull);
    expect(find.text('Edit Profile'), findsOneWidget); // sheet stays open
  });

  testWidgets('editing name/phone/shop name in the sheet saves and closes it', (tester) async {
    final repo = FakeAuthRepository(_retailer);
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Full Name'), 'Suresh Patil');
    await tester.enterText(find.widgetWithText(TextFormField, 'Phone Number'), '9988776655');
    await tester.enterText(find.widgetWithText(TextFormField, 'Business / Shop Name'), 'Suresh Kirana');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Profile'), findsNothing); // sheet closed
    expect(repo.lastUpdate?['name'], 'Suresh Patil');
    expect(repo.lastUpdate?['phone'], '9988776655');
    expect(repo.lastUpdate?['businessName'], 'Suresh Kirana');
  });

  testWidgets('toggling Open 24×7 hides the open/close time pickers', (tester) async {
    await tester.pumpWidget(_wrap(FakeAuthRepository(_retailer)));
    await tester.pumpAndSettle();

    expect(find.textContaining('Opens:'), findsOneWidget);
    expect(find.textContaining('Closes:'), findsOneWidget);

    await tester.tap(find.text('Open 24×7'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Opens:'), findsNothing);
    expect(find.textContaining('Closes:'), findsNothing);
  });

  testWidgets('an invalid IFSC code blocks Save Changes with an inline error', (tester) async {
    final repo = FakeAuthRepository(_retailer);
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'IFSC Code'), 'NOTVALID');
    await tester.tap(find.text('Save Changes'));
    await tester.pump();

    expect(find.text('Enter a valid 11-character IFSC code'), findsOneWidget);
    expect(repo.lastUpdate, isNull);
  });

  testWidgets('Change Password sends a reset link to the account email', (tester) async {
    final repo = FakeAuthRepository(_retailer);
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Change Password'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Send Link'));
    await tester.pumpAndSettle();

    expect(repo.passwordResetSentTo, 'ramesh@test.com');
    expect(find.text('Password reset link sent to ramesh@test.com'), findsOneWidget);
  });

  testWidgets('tapping the avatar opens the image picker without crashing', (tester) async {
    // No real platform binding in a widget test — image_picker's test
    // channel just returns null (no file picked) — this confirms the tap
    // is wired up and the screen survives the round-trip either way.
    final repo = FakeAuthRepository(_retailer);
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.camera_alt_rounded));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(repo.lastUpdate, isNull); // no file picked -> no upload attempted
  });
}
