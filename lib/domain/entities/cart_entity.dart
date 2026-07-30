import 'package:equatable/equatable.dart';
import 'cart_item_entity.dart';
import '../value_objects/money.dart';

class CartEntity extends Equatable {
  final List<CartItemEntity> items;

  const CartEntity({required this.items});

  static const CartEntity empty = CartEntity(items: []);

  Money get subtotal =>
      items.fold(Money.zero, (sum, item) => sum + item.totalPrice);

  /// Badge count for the nav bar and floating cart bar. A weighed line counts
  /// as one item — its `qty` is in grams, so summing it raw would report
  /// "1,000 items" for a single kilo of sugar.
  int get itemCount =>
      items.fold(0, (sum, item) => sum + (item.isWeighed ? 1 : item.qty));

  bool get isEmpty => items.isEmpty;

  /// Quantity of [productId] currently in the cart, or 0 if it isn't in it —
  /// what a product card's qty stepper reads to know its own state.
  int qtyFor(String productId) {
    for (final item in items) {
      if (item.productId == productId) return item.qty;
    }
    return 0;
  }

  @override
  List<Object?> get props => [items];
}
