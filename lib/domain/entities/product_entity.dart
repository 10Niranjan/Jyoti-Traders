import 'package:equatable/equatable.dart';
import '../value_objects/money.dart';

enum ProductUnit {
  kg,
  piece,
  box,
  litre;

  String get value => name;

  static ProductUnit fromString(String unit) {
    return ProductUnit.values.firstWhere(
      (e) => e.name.toLowerCase() == unit.toLowerCase(),
      orElse: () => ProductUnit.piece,
    );
  }
}

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String categoryId;
  final String imageUrl;
  final Money price;
  final ProductUnit unit;
  final int stock;
  final String? description;
  final bool isActive;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.imageUrl,
    required this.price,
    required this.unit,
    required this.stock,
    this.description,
    required this.isActive,
  });

  bool get isInStock => stock > 0;

  @override
  List<Object?> get props =>
      [id, name, categoryId, imageUrl, price, unit, stock, description, isActive];
}
