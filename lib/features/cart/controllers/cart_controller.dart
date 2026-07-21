import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../domain/entities/cart_entity.dart';
import '../../../domain/entities/cart_item_entity.dart';
import '../../../domain/repositories/cart_repository.dart';

class CartController extends StateNotifier<CartEntity> {
  final CartRepository _repository;
  StreamSubscription<CartEntity>? _subscription;

  CartController(this._repository) : super(CartEntity.empty) {
    _subscription = _repository.watchCart().listen((cart) => state = cart);
  }

  Future<void> addItem(CartItemEntity item) => _repository.addItem(item);

  Future<void> removeItem(String productId) => _repository.removeItem(productId);

  Future<void> updateQty(String productId, int qty) => _repository.updateQty(productId, qty);

  Future<void> clearCart() => _repository.clearCart();

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final cartControllerProvider = StateNotifierProvider<CartController, CartEntity>((ref) {
  final repository = ref.watch(cartRepositoryProvider);
  return CartController(repository);
});
