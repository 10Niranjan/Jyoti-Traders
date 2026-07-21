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
