import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/value_objects/money.dart';
import '../../domain/value_objects/weight_rate_slabs.dart';

/// Cart items are stored as plain Maps in Hive (consistent with every other
/// box in `local_storage_service.dart` — no Hive `TypeAdapter` codegen).
class CartItemModel {
  final String productId;
  final String name;
  final String imageUrl;
  final double unitPrice;
  final String unit;

  /// Grams for a slab-priced kg line, otherwise a count of whole units.
  final int qty;
  final WeightRateSlabs? rateSlabs;

  CartItemModel({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.unitPrice,
    required this.unit,
    required this.qty,
    this.rateSlabs,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final rawSlabs = json['rateSlabs'];
    return CartItemModel(
      productId: json['productId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
      unit: json['unit'] as String? ?? 'piece',
      // A line sitting in a cart from before slab pricing has no `rateSlabs`,
      // so its `qty` is still read as whole units and priced flat — no
      // conversion, and no risk of reading an old "5 kg" as 5 grams.
      qty: json['qty'] as int? ?? 0,
      rateSlabs: rawSlabs is Map
          ? WeightRateSlabs.fromJson(Map<String, dynamic>.from(rawSlabs))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'imageUrl': imageUrl,
      'unitPrice': unitPrice,
      'unit': unit,
      'qty': qty,
      'rateSlabs': rateSlabs?.toJson(),
    };
  }

  CartItemEntity toEntity() {
    return CartItemEntity(
      productId: productId,
      name: name,
      imageUrl: imageUrl,
      unitPrice: Money(unitPrice),
      unit: ProductUnit.fromString(unit),
      qty: qty,
      rateSlabs: rateSlabs,
    );
  }

  factory CartItemModel.fromEntity(CartItemEntity entity) {
    return CartItemModel(
      productId: entity.productId,
      name: entity.name,
      imageUrl: entity.imageUrl,
      unitPrice: entity.unitPrice.amount,
      unit: entity.unit.value,
      qty: entity.qty,
      rateSlabs: entity.rateSlabs,
    );
  }
}
