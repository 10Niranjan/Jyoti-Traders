import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/hive_keys.dart';

/// Pure Hive, same `cart_box` the cart itself already opens at startup —
/// reusing it avoids a new `Hive.openBox` call (and everywhere that already
/// opens boxes for tests) just for one more small per-uid list. Keyed by
/// [uid] for the same reason as `CartLocalDatasource`: a different account
/// signing in on this device must never see the previous account's wishlist.
class WishlistLocalDatasource {
  final Box _box;
  final String _uid;
  final _controller = StreamController<Set<String>>.broadcast();

  WishlistLocalDatasource({required Box box, required String uid})
      : _box = box,
        _uid = uid;

  String get _key => '${HiveKeys.wishlistItems}_$_uid';

  Stream<Set<String>> watchWishlist() async* {
    yield _read();
    yield* _controller.stream;
  }

  Future<void> toggle(String productId) async {
    final ids = _read();
    if (!ids.remove(productId)) ids.add(productId);
    await _box.put(_key, ids.toList());
    _controller.add(ids);
  }

  Set<String> _read() {
    final List<dynamic> raw = _box.get(_key, defaultValue: const []);
    return raw.cast<String>().toSet();
  }
}
