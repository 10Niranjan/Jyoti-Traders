import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/value_objects/money.dart';

/// Cart items are stored as plain Maps in Hive (consistent with every other
/// box in `local_storage_service.dart` — no Hive `TypeAdapter` codegen).
class CartItemModel {
  final String productId;
  final String name;
  final String imageUrl;
  final double unitPrice;
  final String unit;
  final int qty;

  CartItemModel({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.unitPrice,
    required this.unit,
    required this.qty,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productId: json['productId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
      unit: json['unit'] as String? ?? 'piece',
      qty: json['qty'] as int? ?? 0,
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
    );
  }
}
