import 'package:equatable/equatable.dart';
import 'cart_item_entity.dart';
import '../value_objects/money.dart';

class CartEntity extends Equatable {
  final List<CartItemEntity> items;

  const CartEntity({required this.items});

  static const CartEntity empty = CartEntity(items: []);

  Money get subtotal =>
      items.fold(Money.zero, (sum, item) => sum + item.totalPrice);

  int get itemCount => items.fold(0, (sum, item) => sum + item.qty);

  bool get isEmpty => items.isEmpty;

  @override
  List<Object?> get props => [items];
}
