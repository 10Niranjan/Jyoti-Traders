import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/data/datasources/local_storage_service.dart';
import 'package:traders_retailer/shared/widgets/first_run_hint.dart';

/// Overrides just the first-run-hint methods so this test never touches a
/// real Hive box — mirrors `FakeLocalStorageService` in
/// `theme_controller_test.dart`.
class FakeLocalStorageService extends LocalStorageService {
  Set<String> stored;
  FakeLocalStorageService([this.stored = const {}]);

  @override
  Set<String> getSeenFirstRunHints() => stored;

  @override
  Future<void> markFirstRunHintSeen(String hintId) async =>
      stored = {...stored, hintId};
}

void main() {
  test('starts empty when nothing is stored', () {
    final controller = FirstRunHintsController(FakeLocalStorageService());
    expect(controller.state, isEmpty);
  });

  test('loads previously-seen hints from storage', () {
    final controller = FirstRunHintsController(
      FakeLocalStorageService({'home_wishlist_icon'}),
    );
    expect(controller.state, {'home_wishlist_icon'});
  });

  test('dismiss adds the hint id to state and persists it', () async {
    final storage = FakeLocalStorageService();
    final controller = FirstRunHintsController(storage);

    await controller.dismiss('floating_cart_bar');

    expect(controller.state, {'floating_cart_bar'});
    expect(storage.stored, {'floating_cart_bar'});
  });

  test('dismiss is a no-op for an already-dismissed hint', () async {
    final storage = FakeLocalStorageService({'floating_cart_bar'});
    final controller = FirstRunHintsController(storage);

    await controller.dismiss('floating_cart_bar');

    expect(controller.state, {'floating_cart_bar'});
  });

  test(
    'dismiss keeps previously-dismissed hints alongside the new one',
    () async {
      final storage = FakeLocalStorageService({'home_wishlist_icon'});
      final controller = FirstRunHintsController(storage);

      await controller.dismiss('home_buy_again_rail');

      expect(controller.state, {'home_wishlist_icon', 'home_buy_again_rail'});
    },
  );
}
