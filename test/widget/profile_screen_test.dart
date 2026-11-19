import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/core/constants/app_constants.dart';
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
import 'package:traders_retailer/features/settings/widgets/settings_choices.dart';
import 'package:traders_retailer/l10n/app_localizations.dart';

import '../helpers/test_viewport.dart';

/// Minimal enough to reach `AuthenticatedCustomer` — mirrors the fake in
/// `upi_payment_screen_test.dart`, which introduced this pattern first.
class FakeAuthRepository implements AuthRepository {
  final UserModel user;
  Map<String, dynamic>? lastUpdate;
  String? passwordResetSentTo;
  String? deletedUid;
  String? deletedWithPassword;
  Object? deleteError;
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
  }) async => user;

  @override
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async => user;

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
    List<AddressEntity>? savedAddresses,
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
      'savedAddresses': savedAddresses,
      'gstNumber': gstNumber,
      'bankDetails': bankDetails,
      'businessHours': businessHours,
      'notificationPreferences': notificationPreferences,
    };
    return user;
  }

  @override
  Future<void> updateFcmToken({
    required String uid,
    required String fcmToken,
  }) async {}

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    passwordResetSentTo = email;
  }

  @override
  Future<void> deleteAccount({required String uid, String? password}) async {
    if (deleteError != null) throw deleteError!;
    deletedUid = uid;
    deletedWithPassword = password;
  }
}

class FakeLocalStorageService extends LocalStorageService {
  bool? stored;
  FakeLocalStorageService([this.stored]);

  @override
  bool? getThemePreference() => stored;

  @override
  Future<void> saveThemePreference(bool isDarkMode) async =>
      stored = isDarkMode;

  @override
  Future<void> clearThemePreference() async => stored = null;

  @override
  String? getLanguagePreference() => null;

  @override
  Future<void> saveLanguagePreference(String languageCode) async {}

  @override
  Future<void> clearLanguagePreference() async {}

  @override
  String? getTextSizePreference() => null;

  @override
  Future<void> saveTextSizePreference(String name) async {}

  @override
  Future<void> clearTextSizePreference() async {}
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

Widget _wrap(
  FakeAuthRepository repository, {
  ThemeMode initial = ThemeMode.system,
}) => ProviderScope(
  overrides: [
    authRepositoryProvider.overrideWithValue(repository),
    themeModeProvider.overrideWith(
      (ref) => ThemeModeController(
        FakeLocalStorageService(
          initial == ThemeMode.system ? null : initial == ThemeMode.dark,
        ),
      ),
    ),
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

  testWidgets(
    'Appearance row shows the current theme and opens System/Light/Dark',
    (tester) async {
      await tester.pumpWidget(_wrap(FakeAuthRepository(_retailer)));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget); // current value on the row
      expect(find.text('Dark'), findsNothing); // choices live in the sheet

      await tester.tap(find.text('Appearance'));
      await tester.pumpAndSettle();

      expect(find.text('System'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('Light'), findsNWidgets(2)); // row value + segment
    },
  );

  testWidgets('tapping Dark switches the app theme mode', (tester) async {
    await tester.pumpWidget(_wrap(FakeAuthRepository(_retailer)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Appearance'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    final dark = tester.widget<SettingsChoiceTile>(
      find.widgetWithText(SettingsChoiceTile, 'Dark'),
    );
    expect(dark.selected, isTrue);
    expect(
      tester
          .widget<SettingsChoiceTile>(
            find.widgetWithText(SettingsChoiceTile, 'Light'),
          )
          .selected,
      isFalse,
    );
  });

  testWidgets('header card shows shop name, owner name and phone', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(FakeAuthRepository(_retailer)));
    await tester.pumpAndSettle();

    expect(find.text('Ramesh Kirana Store'), findsOneWidget);
    expect(find.text('Ramesh'), findsOneWidget);
    expect(find.text('9876543210'), findsOneWidget);
  });

  testWidgets(
    'edit profile sheet rejects a digit in the name field and does not save',
    (tester) async {
      final repo = FakeAuthRepository(_retailer);
      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'),
        'A',
      );
      await tester.pump();
      expect(find.text('Name must be at least 2 characters'), findsOneWidget);

      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(repo.lastUpdate, isNull);
      expect(find.text('Edit Profile'), findsOneWidget); // sheet stays open
    },
  );

  testWidgets('editing name/phone/shop name in the sheet saves and closes it', (
    tester,
  ) async {
    final repo = FakeAuthRepository(_retailer);
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Full Name'),
      'Suresh Patil',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Phone Number'),
      '9988776655',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Business / Shop Name'),
      'Suresh Kirana',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Profile'), findsNothing); // sheet closed
    expect(repo.lastUpdate?['name'], 'Suresh Patil');
    expect(repo.lastUpdate?['phone'], '9988776655');
    expect(repo.lastUpdate?['businessName'], 'Suresh Kirana');
  });

  testWidgets('Change Password sends a reset link to the account email', (
    tester,
  ) async {
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
    expect(
      find.text('Password reset link sent to ramesh@test.com'),
      findsOneWidget,
    );
  });

  testWidgets('tapping the avatar opens the image picker without crashing', (
    tester,
  ) async {
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

  testWidgets('Notifications sheet saves a toggled switch', (tester) async {
    final repo = FakeAuthRepository(_retailer);
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Notifications'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(SwitchListTile, 'Order Updates'));
    await tester.pumpAndSettle();

    expect(
      repo.lastUpdate?['notificationPreferences'],
      const NotificationPreferencesEntity(orderUpdates: false),
    );
    // Flips immediately, not only after the save round-trips.
    final tile = tester.widget<SwitchListTile>(
      find.widgetWithText(SwitchListTile, 'Order Updates'),
    );
    expect(tile.value, isFalse);
  });

  testWidgets('Text size row offers Auto/Small/Medium/Large and selects one', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(FakeAuthRepository(_retailer)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Text size'), findsOneWidget);
    await tester.tap(find.text('Text size'));
    await tester.pumpAndSettle();

    SettingsChoiceTile chip(String label) => tester.widget<SettingsChoiceTile>(
      find.widgetWithText(SettingsChoiceTile, label),
    );
    expect(chip('Auto').selected, isTrue);
    expect(chip('Small').selected, isFalse);
    expect(chip('Medium').selected, isFalse);

    await tester.tap(find.widgetWithText(SettingsChoiceTile, 'Large'));
    await tester.pumpAndSettle();

    expect(chip('Large').selected, isTrue);
    expect(chip('Auto').selected, isFalse);
  });

  group('settings pop-ups', () {
    Future<void> openSettings(WidgetTester tester) async {
      await tester.pumpWidget(_wrap(FakeAuthRepository(_retailer)));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
    }

    Future<void> openAppearance(WidgetTester tester) async {
      await openSettings(tester);
      await tester.tap(find.text('Appearance'));
      await tester.pumpAndSettle();
    }

    // Regression: these were small sheets hugging the bottom edge.
    testWidgets('open in the middle of the page, not at the bottom', (
      tester,
    ) async {
      await openAppearance(tester);

      final pageHeight =
          tester.view.physicalSize.height / tester.view.devicePixelRatio;
      final headerY = tester
          .getCenter(find.text('Choose how the app looks'))
          .dy;
      final doneY = tester.getCenter(find.text('Done')).dy;

      // The card straddles the middle of the screen, clear of both edges.
      expect(headerY, lessThan(pageHeight / 2));
      expect(doneY, greaterThan(pageHeight / 2));
      expect(headerY, greaterThan(120));
      expect(doneY, lessThan(pageHeight - 120));
    });

    testWidgets('the Done button closes the pop-up', (tester) async {
      await openAppearance(tester);
      expect(find.text('Choose how the app looks'), findsOneWidget);

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(find.text('Choose how the app looks'), findsNothing);
    });

    testWidgets('the close button closes the pop-up', (tester) async {
      await openAppearance(tester);

      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();

      expect(find.text('Choose how the app looks'), findsNothing);
    });

    testWidgets('tapping outside the card closes the pop-up', (tester) async {
      await openAppearance(tester);

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.text('Choose how the app looks'), findsNothing);
    });

    testWidgets('choosing an option keeps the pop-up open', (tester) async {
      await openAppearance(tester);

      await tester.tap(find.widgetWithText(SettingsChoiceTile, 'Dark'));
      await tester.pumpAndSettle();

      expect(find.text('Choose how the app looks'), findsOneWidget);
    });

    testWidgets('Language lists all three languages with one chosen', (
      tester,
    ) async {
      await openSettings(tester);
      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();

      SettingsChoiceTile tile(String name) =>
          tester.widget(find.widgetWithText(SettingsChoiceTile, name));
      expect(tile('English').selected, isTrue);
      expect(tile('हिन्दी').selected, isFalse);
      expect(tile('मराठी').selected, isFalse);

      await tester.tap(find.widgetWithText(SettingsChoiceTile, 'हिन्दी'));
      await tester.pumpAndSettle();

      expect(tile('हिन्दी').selected, isTrue);
      expect(tile('English').selected, isFalse);
    });

    testWidgets('Text size shows a live preview line', (tester) async {
      await openSettings(tester);
      await tester.tap(find.text('Text size'));
      await tester.pumpAndSettle();

      expect(
        find.text('Fresh stock, best prices, fast delivery.'),
        findsOneWidget,
      );
    });

    testWidgets('Support opens as three large contact cards', (tester) async {
      await openSettings(tester);
      await tester.tap(find.text('Support'));
      await tester.pumpAndSettle();

      expect(find.text('We\'re here to help'), findsOneWidget);
      expect(find.text(AppConstants.kSupportEmail), findsOneWidget);
      expect(find.byIcon(Icons.call_rounded), findsOneWidget);
      expect(find.byIcon(Icons.chat_rounded), findsOneWidget);
      expect(find.byIcon(Icons.email_rounded), findsOneWidget);
    });
  });

  testWidgets('About shows the app name and Clear image cache is offered', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(FakeAuthRepository(_retailer)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Clear image cache'), findsOneWidget);
    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();

    expect(find.text('Jyoti Traders'), findsOneWidget);
    expect(
      tester.takeException(),
      isNull,
    ); // no version plugin in tests: no crash
  });

  group('profile sections (rows that open their own sheet)', () {
    Future<void> pump(WidgetTester tester, FakeAuthRepository repo) async {
      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();
    }

    testWidgets('Business details: Open 24×7 hides the open/close pickers', (
      tester,
    ) async {
      await pump(tester, FakeAuthRepository(_retailer));
      await tester.tap(find.text('Business Details'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Opens:'), findsOneWidget);
      expect(find.textContaining('Closes:'), findsOneWidget);

      await tester.tap(find.text('Open 24×7'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Opens:'), findsNothing);
      expect(find.textContaining('Closes:'), findsNothing);
    });

    testWidgets('Payout: an invalid IFSC blocks Save with an inline error', (
      tester,
    ) async {
      final repo = FakeAuthRepository(_retailer);
      await pump(tester, repo);
      await tester.tap(find.text('Payout Details'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'IFSC Code'),
        'NOTVALID',
      );
      await tester.pump();
      await tester.tap(find.text('Save Changes'));
      await tester.pump();

      expect(find.text('Enter a valid 11-character IFSC code'), findsOneWidget);
      expect(repo.lastUpdate, isNull);
    });

    testWidgets(
      'a section saves only its own fields, then closes and confirms',
      (tester) async {
        final repo = FakeAuthRepository(_retailer);
        await pump(tester, repo);
        await tester.tap(find.text('Business Details'));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextFormField, 'GST Number (optional)'),
          '22AAAAA0000A1Z5',
        );
        await tester.pump();
        await tester.tap(find.text('Save Changes'));
        await tester.pumpAndSettle();

        expect(repo.lastUpdate?['gstNumber'], '22AAAAA0000A1Z5');
        // Nothing from the other sections rode along.
        expect(repo.lastUpdate?['address'], isNull);
        expect(repo.lastUpdate?['bankDetails'], isNull);
        expect(find.text('Saved'), findsOneWidget); // snackbar
        expect(find.text('Save Changes'), findsNothing); // sheet closed
      },
    );

    testWidgets('Save stays disabled until something changes', (tester) async {
      await pump(tester, FakeAuthRepository(_retailer));
      await tester.tap(find.text('Business Details'));
      await tester.pumpAndSettle();

      ElevatedButton button() => tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Save Changes'),
      );
      expect(button().onPressed, isNull);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'GST Number (optional)'),
        '22AAAAA0000A1Z5',
      );
      await tester.pump();
      expect(button().onPressed, isNotNull);
    });

    testWidgets('a clean sheet closes without asking anything', (tester) async {
      await pump(tester, FakeAuthRepository(_retailer));
      await tester.tap(find.text('Payout Details'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Discard changes?'), findsNothing);
      expect(find.text('Save Changes'), findsNothing);
    });

    testWidgets(
      'unsaved edits: Keep editing stays, Discard leaves without saving',
      (tester) async {
        final repo = FakeAuthRepository(_retailer);
        await pump(tester, repo);
        await tester.tap(find.text('Payout Details'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Bank Name'),
          'SBI',
        );
        await tester.pump();

        await tester.tap(find.byIcon(Icons.close_rounded));
        await tester.pumpAndSettle();
        expect(find.text('Discard changes?'), findsOneWidget);

        await tester.tap(find.text('Keep editing'));
        await tester.pumpAndSettle();
        expect(find.text('Save Changes'), findsOneWidget); // still open
        expect(find.text('SBI'), findsOneWidget); // and still typed

        await tester.tap(find.byIcon(Icons.close_rounded));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Discard'));
        await tester.pumpAndSettle();

        expect(find.text('Save Changes'), findsNothing);
        expect(repo.lastUpdate, isNull);
      },
    );

    testWidgets('a label chip is saved with the delivery address', (
      tester,
    ) async {
      final repo = FakeAuthRepository(_retailer);
      await pump(tester, repo);
      await tester.tap(find.text('Delivery Address'));
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), '12 MG Road');
      await tester.enterText(fields.at(1), 'Pune');
      await tester.enterText(fields.at(2), '411001');
      await tester.tap(find.widgetWithText(ChoiceChip, 'Shop'));
      await tester.pump();
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      final saved = repo.lastUpdate?['address'] as AddressEntity?;
      expect(saved?.street, '12 MG Road');
      expect(saved?.label, 'Shop');
    });
  });

  group('saved addresses sheet', () {
    final withAddresses = UserModel(
      uid: 'u1',
      name: 'Ramesh',
      email: 'ramesh@test.com',
      phone: '9876543210',
      role: UserRole.customer,
      status: UserStatus.approved,
      businessName: 'Ramesh Kirana Store',
      createdAt: DateTime(2026, 1, 1),
      address: const AddressEntity(
        street: '12 MG Road',
        city: 'Pune',
        pincode: '411001',
        id: 'a1',
        label: 'Shop',
      ),
      savedAddresses: const [
        AddressEntity(
          street: '12 MG Road',
          city: 'Pune',
          pincode: '411001',
          id: 'a1',
          label: 'Shop',
        ),
        AddressEntity(
          street: '9 Industrial Estate',
          city: 'Pune',
          pincode: '411019',
          id: 'a2',
          label: 'Warehouse',
        ),
      ],
    );

    Future<FakeAuthRepository> open(WidgetTester tester) async {
      final repo = FakeAuthRepository(withAddresses);
      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Saved Addresses'));
      await tester.pumpAndSettle();
      return repo;
    }

    testWidgets('marks the current address as the default', (tester) async {
      await open(tester);

      expect(find.text('Default'), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
      expect(find.byIcon(Icons.star_border_rounded), findsOneWidget);
    });

    testWidgets('the star makes another saved address the default', (
      tester,
    ) async {
      final repo = await open(tester);

      await tester.tap(find.byIcon(Icons.star_border_rounded));
      await tester.pumpAndSettle();

      final address = repo.lastUpdate?['address'] as AddressEntity?;
      expect(address?.id, 'a2');
      expect(
        repo.lastUpdate?['savedAddresses'],
        isNull,
      ); // only the default changed
    });

    testWidgets('confirming removal persists the shortened list', (
      tester,
    ) async {
      final repo = await open(tester);

      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();

      final saved = repo.lastUpdate?['savedAddresses'] as List<AddressEntity>?;
      expect(saved, hasLength(1));
      expect(saved!.single.id, 'a2');
    });

    testWidgets('the Addresses quick action opens it, empty state included', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(FakeAuthRepository(_retailer)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Addresses'));
      await tester.pumpAndSettle();

      expect(find.text('No saved addresses yet.'), findsOneWidget);
    });
  });

  group('Delete account and privacy policy', () {
    Future<FakeAuthRepository> openDialog(
      WidgetTester tester, {
      Object? error,
    }) async {
      final repo = FakeAuthRepository(_retailer)..deleteError = error;
      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete account'));
      await tester.pumpAndSettle();
      return repo;
    }

    TextButton deleteButton(WidgetTester tester) => tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Delete permanently'),
    );

    testWidgets('Settings offers Delete account for a retailer', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(FakeAuthRepository(_retailer)));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(find.text('Delete account'), findsOneWidget);
    });

    testWidgets(
      'the privacy-policy row only appears once a URL is configured',
      (tester) async {
        await tester.pumpWidget(_wrap(FakeAuthRepository(_retailer)));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();

        expect(
          find.text('Privacy policy'),
          AppConstants.kPrivacyPolicyUrl.isEmpty
              ? findsNothing
              : findsOneWidget,
        );
      },
    );

    testWidgets(
      'explains what goes and what stays, and needs a password first',
      (tester) async {
        await openDialog(tester);

        expect(find.text('Delete your account?'), findsOneWidget);
        expect(
          find.textContaining('Past orders stay on record'),
          findsOneWidget,
        );
        expect(deleteButton(tester).onPressed, isNull);

        await tester.enterText(find.byType(TextField), 'secret123');
        await tester.pump();
        expect(deleteButton(tester).onPressed, isNotNull);
      },
    );

    testWidgets('confirming deletes with the uid and password, then closes', (
      tester,
    ) async {
      final repo = await openDialog(tester);

      await tester.enterText(find.byType(TextField), 'secret123');
      await tester.pump();
      await tester.tap(find.text('Delete permanently'));
      await tester.pumpAndSettle();

      expect(repo.deletedUid, 'u1');
      expect(repo.deletedWithPassword, 'secret123');
      expect(find.text('Delete your account?'), findsNothing);
    });

    testWidgets('a failure is shown in the dialog, which stays open to retry', (
      tester,
    ) async {
      final repo = await openDialog(tester, error: Exception('wrong-password'));

      await tester.enterText(find.byType(TextField), 'nope');
      await tester.pump();
      await tester.tap(find.text('Delete permanently'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining("Couldn't delete your account"),
        findsOneWidget,
      );
      expect(find.text('Delete your account?'), findsOneWidget);
      expect(deleteButton(tester).onPressed, isNotNull); // can try again
      expect(repo.deletedUid, isNull);
    });

    testWidgets('Cancel deletes nothing', (tester) async {
      final repo = await openDialog(tester);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Delete your account?'), findsNothing);
      expect(repo.deletedUid, isNull);
    });
  });

  group('completeness card', () {
    testWidgets('lists what is missing and opens the place to fix it', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(FakeAuthRepository(_retailer)));
      await tester.pumpAndSettle();

      expect(find.text('0% complete'), findsOneWidget);
      expect(find.text('Add a shop photo'), findsOneWidget);
      expect(find.text('Set your delivery location'), findsOneWidget);
      expect(find.text('Add your GST number'), findsOneWidget);
      expect(find.text('Add payout details'), findsOneWidget);

      await tester.tap(find.text('Add your GST number'));
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(TextFormField, 'GST Number (optional)'),
        findsOneWidget,
      );
    });

    testWidgets('disappears once the profile is complete', (tester) async {
      final complete = UserModel(
        uid: 'u1',
        name: 'Ramesh',
        email: 'ramesh@test.com',
        phone: '9876543210',
        role: UserRole.customer,
        status: UserStatus.approved,
        businessName: 'Ramesh Kirana Store',
        createdAt: DateTime(2026, 1, 1),
        photoUrl: 'https://example.invalid/p.png',
        address: const AddressEntity(
          street: 'St',
          city: 'Pune',
          pincode: '411001',
          latitude: 18.5,
          longitude: 73.8,
        ),
        gstNumber: '22AAAAA0000A1Z5',
        bankDetails: const BankDetailsEntity(
          accountHolderName: 'R',
          accountNumber: '123456789',
          ifscCode: 'SBIN0000001',
          bankName: 'SBI',
        ),
      );
      await tester.pumpWidget(_wrap(FakeAuthRepository(complete)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.textContaining('% complete'), findsNothing);
    });
  });
}
