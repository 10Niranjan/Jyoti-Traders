import 'package:equatable/equatable.dart';
import '../value_objects/money.dart';

/// A single line item within a placed order — a frozen snapshot of the
/// product's name/price at the time the order was placed.
class OrderItemEntity extends Equatable {
  final String productId;
  final String name;
  final int qty;
  final Money unitPrice;

  const OrderItemEntity({
    required this.productId,
    required this.name,
    required this.qty,
    required this.unitPrice,
  });

  Money get totalPrice => Money(unitPrice.amount * qty);

  @override
  List<Object?> get props => [productId, name, qty, unitPrice];
}
