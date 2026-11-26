import '../value_objects/money.dart';

/// Thrown when an order total falls below the enforced minimum (PRD §3).
class MinimumOrderException implements Exception {
  final Money orderTotal;
  final Money minimumRequired;

  MinimumOrderException({required this.orderTotal, required this.minimumRequired});

  @override
  String toString() =>
      'Order total ${orderTotal.formatted} is below the minimum order amount of ${minimumRequired.formatted}';
}

/// Thrown when a cart line asks for more than is in stock right now.
/// [available] is a ready-to-show amount (`2 box`, `1.5 kg`), or null when
/// the product is gone, inactive or sold out.
class InsufficientStockException implements Exception {
  final String productName;
  final String? available;

  InsufficientStockException({required this.productName, this.available});

  @override
  String toString() => available == null
      ? '$productName is no longer available'
      : 'Only $available of $productName is left';
}
