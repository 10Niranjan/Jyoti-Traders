import 'package:equatable/equatable.dart';
import '../../core/utils/weight_formatter.dart';
import '../value_objects/money.dart';
import '../value_objects/weight_rate_slabs.dart';

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

  /// For piece/box/litre products this is the price of one unit. For a kg
  /// product with [rateSlabs] it's only a display figure (the small-quantity
  /// rate) — the amount actually charged comes from the slabs.
  final Money price;
  final ProductUnit unit;
  final int stock;
  final String? description;
  final bool isActive;

  /// Set only on kg products, and only once an admin has entered rates.
  /// A kg product saved before slab pricing existed leaves this null and
  /// keeps its old flat price-per-kilo behaviour.
  final WeightRateSlabs? rateSlabs;

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
    this.rateSlabs,
  });

  bool get isInStock => stock > 0;

  /// True when this product is bought by weight, so quantities are grams and
  /// the price comes off the slab ladder.
  bool get isWeighed => unit == ProductUnit.kg && rateSlabs != null;

  /// Line total for [qty] — grams when [isWeighed], whole units otherwise.
  Money priceForQty(int qty) =>
      isWeighed ? rateSlabs!.priceFor(qty) : Money(price.amount * qty);

  /// Largest quantity the picker may reach, in the same unit [qty] is in.
  /// [stock] is counted in kilos for weighed products, so it scales up.
  int get maxQty => isWeighed ? stock * 1000 : stock;

  /// Smallest sensible starting quantity — 100 g, or one whole unit.
  int get minQty => isWeighed ? 100 : 1;

  /// How [qty] reads in prose: `2.5 kg`, or `3 box`.
  String labelForQty(int qty) => isWeighed ? formatGrams(qty) : '$qty ${unit.value}';

  ProductEntity copyWith({String? imageUrl}) {
    return ProductEntity(
      id: id,
      name: name,
      categoryId: categoryId,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price,
      unit: unit,
      stock: stock,
      description: description,
      isActive: isActive,
      rateSlabs: rateSlabs,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, categoryId, imageUrl, price, unit, stock, description, isActive, rateSlabs];
}
