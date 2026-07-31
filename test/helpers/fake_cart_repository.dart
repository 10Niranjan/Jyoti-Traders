import 'dart:async';

import 'package:traders_retailer/domain/entities/cart_entity.dart';
import 'package:traders_retailer/domain/entities/cart_item_entity.dart';
import 'package:traders_retailer/domain/repositories/cart_repository.dart';

/// In-memory stand-in for the Hive-backed cart, mirroring the one behaviour
/// widgets actually depend on: `addItem` *sums* into an existing line while
/// `updateQty` *sets* it (see `CartLocalDatasource`).
class FakeCartRepository implements CartRepository {
  List<CartItemEntity> items;
  final _controller = StreamController<CartEntity>.broadcast();

  FakeCartRepository([this.items = const []]);

  @override
  Stream<CartEntity> watchCart() async* {
    yield CartEntity(items: items);
    yield* _controller.stream;
  }

  @override
  Future<void> addItem(CartItemEntity item) async {
    final idx = items.indexWhere((i) => i.productId == item.productId);
    if (idx == -1) {
      items = [...items, item];
    } else {
      items = [...items]..[idx] = items[idx].copyWith(qty: items[idx].qty + item.qty);
    }
    _controller.add(CartEntity(items: items));
  }

  @override
  Future<void> removeItem(String productId) async {
    items = items.where((i) => i.productId != productId).toList();
    _controller.add(CartEntity(items: items));
  }

  @override
  Future<void> updateQty(String productId, int qty) async {
    if (qty <= 0) {
      items = items.where((i) => i.productId != productId).toList();
    } else {
      final idx = items.indexWhere((i) => i.productId == productId);
      if (idx != -1) items = [...items]..[idx] = items[idx].copyWith(qty: qty);
    }
    _controller.add(CartEntity(items: items));
  }

  @override
  Future<void> clearCart() async {
    items = [];
    _controller.add(CartEntity(items: items));
  }
}
