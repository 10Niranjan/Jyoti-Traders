/// Local-only, mirroring `CartRepository` — a wishlist is a per-device
/// convenience, not something that needs to sync or be visible to the admin.
abstract class WishlistRepository {
  Stream<Set<String>> watchWishlist();

  /// Adds [productId] if absent, removes it if present.
  Future<void> toggle(String productId);
}
