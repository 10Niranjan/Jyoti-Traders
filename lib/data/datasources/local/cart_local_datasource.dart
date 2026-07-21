import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/hive_keys.dart';
import '../../models/cart_item_model.dart';

/// Pure Hive — the cart never touches Firestore (cleared locally on
/// successful order placement, per ARCHITECTURE.md §4.2).
class CartLocalDatasource {
  final Box _cartBox;
  final _controller = StreamController<List<CartItemModel>>.broadcast();

  CartLocalDatasource({required Box cartBox}) : _cartBox = cartBox;

  Stream<List<CartItemModel>> watchCart() async* {
    yield _read();
    yield* _controller.stream;
  }

  Future<void> addItem(CartItemModel item) async {
    final items = _read();
    final idx = items.indexWhere((i) => i.productId == item.productId);
    if (idx != -1) {
      final existing = items[idx];
      items[idx] = CartItemModel(
        productId: existing.productId,
        name: existing.name,
        imageUrl: existing.imageUrl,
        unitPrice: existing.unitPrice,
        unit: existing.unit,
        qty: existing.qty + item.qty,
      );
    } else {
      items.add(item);
    }
    await _save(items);
  }

  Future<void> removeItem(String productId) async {
    final items = _read()..removeWhere((i) => i.productId == productId);
    await _save(items);
  }

  Future<void> updateQty(String productId, int qty) async {
    final items = _read();
    final idx = items.indexWhere((i) => i.productId == productId);
    if (idx == -1) return;
    if (qty <= 0) {
      items.removeAt(idx);
    } else {
      final existing = items[idx];
      items[idx] = CartItemModel(
        productId: existing.productId,
        name: existing.name,
        imageUrl: existing.imageUrl,
        unitPrice: existing.unitPrice,
        unit: existing.unit,
        qty: qty,
      );
    }
    await _save(items);
  }

  Future<void> clearCart() async {
    await _save([]);
  }

  List<CartItemModel> _read() {
    final List<dynamic> raw = _cartBox.get(HiveKeys.cartItems, defaultValue: []);
    return raw.map((e) => CartItemModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<void> _save(List<CartItemModel> items) async {
    await _cartBox.put(HiveKeys.cartItems, items.map((i) => i.toJson()).toList());
    _controller.add(items);
  }
}
