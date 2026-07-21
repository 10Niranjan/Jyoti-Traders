import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/local/cart_local_datasource.dart';
import '../models/cart_item_model.dart';

class CartRepositoryImpl implements CartRepository {
  final CartLocalDatasource _local;

  CartRepositoryImpl(this._local);

  @override
  Stream<CartEntity> watchCart() {
    return _local.watchCart().map(
          (list) => CartEntity(items: list.map((m) => m.toEntity()).toList()),
        );
  }

  @override
  Future<void> addItem(CartItemEntity item) {
    return _local.addItem(CartItemModel.fromEntity(item));
  }

  @override
  Future<void> removeItem(String productId) {
    return _local.removeItem(productId);
  }

  @override
  Future<void> updateQty(String productId, int qty) {
    return _local.updateQty(productId, qty);
  }

  @override
  Future<void> clearCart() {
    return _local.clearCart();
  }
}
