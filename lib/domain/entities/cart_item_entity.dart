import 'package:equatable/equatable.dart';
import 'product_entity.dart';
import '../value_objects/money.dart';
import '../value_objects/weight_rate_slabs.dart';

class CartItemEntity extends Equatable {
  final String productId;
  final String name;
  final String imageUrl;
  final Money unitPrice;
  final ProductUnit unit;

  /// Grams when [isWeighed], otherwise a count of whole units.
  final int qty;

  /// Snapshotted with the line so changing the quantity in the cart re-prices
  /// against the same ladder the retailer saw on the product page.
  final WeightRateSlabs? rateSlabs;

  const CartItemEntity({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.unitPrice,
    required this.unit,
    required this.qty,
    this.rateSlabs,
  });

  bool get isWeighed => unit == ProductUnit.kg && rateSlabs != null;

  /// ₹/kg this line currently earns — falls to the next band as qty grows.
  double? get ratePerKg => rateSlabs?.ratePerKgFor(qty);

  Money get totalPrice =>
      isWeighed ? rateSlabs!.priceFor(qty) : Money(unitPrice.amount * qty);

  CartItemEntity copyWith({int? qty}) {
    return CartItemEntity(
      productId: productId,
      name: name,
      imageUrl: imageUrl,
      unitPrice: unitPrice,
      unit: unit,
      qty: qty ?? this.qty,
      rateSlabs: rateSlabs,
    );
  }

  @override
  List<Object?> get props => [productId, name, imageUrl, unitPrice, unit, qty, rateSlabs];
}
