import 'package:equatable/equatable.dart';
import 'product_entity.dart';
import '../value_objects/money.dart';

class CartItemEntity extends Equatable {
  final String productId;
  final String name;
  final String imageUrl;
  final Money unitPrice;
  final ProductUnit unit;
  final int qty;

  const CartItemEntity({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.unitPrice,
    required this.unit,
    required this.qty,
  });

  Money get totalPrice => Money(unitPrice.amount * qty);

  CartItemEntity copyWith({int? qty}) {
    return CartItemEntity(
      productId: productId,
      name: name,
      imageUrl: imageUrl,
      unitPrice: unitPrice,
      unit: unit,
      qty: qty ?? this.qty,
    );
  }

  @override
  List<Object?> get props => [productId, name, imageUrl, unitPrice, unit, qty];
}
