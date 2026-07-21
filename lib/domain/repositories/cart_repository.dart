import '../entities/cart_entity.dart';
import '../entities/cart_item_entity.dart';

/// Local-only — the cart never touches Firestore (PRD/ARCHITECTURE: cart is
/// Hive-backed and cleared on successful order placement).
abstract class CartRepository {
  Stream<CartEntity> watchCart();

  Future<void> addItem(CartItemEntity item);

  Future<void> removeItem(String productId);

  Future<void> updateQty(String productId, int qty);

  Future<void> clearCart();
}
