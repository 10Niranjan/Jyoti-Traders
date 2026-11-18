import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:traders_retailer/core/constants/hive_keys.dart';
import 'package:traders_retailer/data/models/user_model.dart';
import 'package:traders_retailer/data/repositories/auth_repository_provider.dart';
import 'package:traders_retailer/data/repositories/repository_providers.dart';

import '../../helpers/fake_auth_repository.dart';

class _StreamingAuth extends FakeAuthRepository {
  final users = StreamController<UserModel?>();
  _StreamingAuth(super.user);

  @override
  Stream<UserModel?> get authStateChanges => users.stream;
}

UserModel _user(String uid, String shop) => UserModel(
  uid: uid,
  name: 'Ramesh',
  email: '$uid@test.com',
  phone: '9876543210',
  role: UserRole.customer,
  status: UserStatus.approved,
  businessName: shop,
  createdAt: DateTime(2026, 1, 1),
);

/// Regression: Checkout saves the address to the profile, which emits a new
/// auth state for the *same* user. The cart repository used to rebuild on
/// that, disposing the checkout controller mid-order — the order was placed
/// but the screen never moved on to Order Success.
void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('jyoti_cart_scope_');
    Hive.init(tempDir.path);
    await Hive.openBox(HiveBoxes.cartBox);
  });

  tearDown(() async {
    await Hive.close();
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  test(
    'cart repository survives a profile update, rebuilds on account switch',
    () async {
      final auth = _StreamingAuth(_user('u1', 'Old Name'));
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(auth)],
      );
      addTearDown(container.dispose);
      container.listen(cartRepositoryProvider, (_, _) {});

      auth.users.add(_user('u1', 'Old Name'));
      await Future<void>.delayed(Duration.zero);
      final first = container.read(cartRepositoryProvider);

      // Same account, new profile data (what Checkout's address save emits).
      auth.users.add(_user('u1', 'New Name'));
      await Future<void>.delayed(Duration.zero);
      expect(identical(container.read(cartRepositoryProvider), first), isTrue);

      // A different account must get its own cart.
      auth.users.add(_user('u2', 'Other Shop'));
      await Future<void>.delayed(Duration.zero);
      expect(identical(container.read(cartRepositoryProvider), first), isFalse);
    },
  );
}
