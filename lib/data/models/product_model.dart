import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/value_objects/money.dart';
import '../../domain/value_objects/weight_rate_slabs.dart';

class ProductModel {
  final String id;
  final String name;
  final String categoryId;
  final String imageUrl;
  final double price;
  final String unit;
  final int stock;
  final String? description;
  final bool isActive;
  final WeightRateSlabs? rateSlabs;

  ProductModel({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.imageUrl,
    required this.price,
    required this.unit,
    required this.stock,
    this.description,
    required this.isActive,
    this.rateSlabs,
  });

  /// Absent on every product saved before slab pricing shipped — those keep
  /// their flat price-per-unit behaviour with no migration needed.
  static WeightRateSlabs? _slabsFrom(Map<String, dynamic> json) {
    final raw = json['rateSlabs'];
    return raw is Map ? WeightRateSlabs.fromJson(Map<String, dynamic>.from(raw)) : null;
  }

  factory ProductModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final json = doc.data() ?? {};
    return ProductModel(
      id: doc.id,
      name: json['name'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      unit: json['unit'] as String? ?? 'piece',
      stock: json['stock'] as int? ?? 0,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      rateSlabs: _slabsFrom(json),
    );
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      unit: json['unit'] as String? ?? 'piece',
      stock: json['stock'] as int? ?? 0,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      rateSlabs: _slabsFrom(json),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'categoryId': categoryId,
      'imageUrl': imageUrl,
      'price': price,
      'unit': unit,
      'stock': stock,
      'description': description,
      'isActive': isActive,
      'rateSlabs': rateSlabs?.toJson(),
      // Plain DateTime, not Timestamp.now() — this map is also written to
      // Hive in simulation mode, which cannot serialize Timestamp directly.
      // Firestore auto-converts DateTime -> Timestamp on write.
      'updatedAt': DateTime.now(),
    };
  }

  Map<String, dynamic> toJson() => {'id': id, ...toFirestore()};

  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      name: name,
      categoryId: categoryId,
      imageUrl: imageUrl,
      price: Money(price),
      unit: ProductUnit.fromString(unit),
      stock: stock,
      description: description,
      isActive: isActive,
      rateSlabs: rateSlabs,
    );
  }

  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      name: entity.name,
      categoryId: entity.categoryId,
      imageUrl: entity.imageUrl,
      price: entity.price.amount,
      unit: entity.unit.value,
      stock: entity.stock,
      description: entity.description,
      isActive: entity.isActive,
      rateSlabs: entity.rateSlabs,
    );
  }
}
