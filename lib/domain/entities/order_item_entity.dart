import 'package:equatable/equatable.dart';
import 'product_entity.dart';
import '../value_objects/money.dart';

/// A single line item within a placed order — a frozen snapshot of the
/// product's name/price at the time the order was placed.
class OrderItemEntity extends Equatable {
  final String productId;
  final String name;

  /// Grams when [isWeighed], otherwise a count of whole units.
  final int qty;

  /// What one unit cost — ₹/kg for a weighed line, at the band it earned.
  final Money unitPrice;

  /// Null on orders placed before slab pricing existed; those render as a
  /// bare count, exactly as they always did.
  final ProductUnit? unit;

  /// Frozen line total. Stored rather than recomputed because a weighed line
  /// was priced off a rate ladder that may since have been edited — an old
  /// order must never re-price itself.
  final Money? lineTotal;

  const OrderItemEntity({
    required this.productId,
    required this.name,
    required this.qty,
    required this.unitPrice,
    this.unit,
    this.lineTotal,
  });

  bool get isWeighed => unit == ProductUnit.kg && lineTotal != null;

  Money get totalPrice => lineTotal ?? Money(unitPrice.amount * qty);

  @override
  List<Object?> get props => [productId, name, qty, unitPrice, unit, lineTotal];
}
