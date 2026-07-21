import '../../../core/constants/app_constants.dart';
import '../../entities/order_entity.dart';
import '../../exceptions/domain_exceptions.dart';
import '../../repositories/order_repository.dart';
import '../../value_objects/money.dart';

class PlaceOrderUseCase {
  final OrderRepository _repository;

  PlaceOrderUseCase(this._repository);

  /// Places [order], enforcing the ₹2,500 minimum order rule one final time
  /// before it's written — the UI must also block checkout below this
  /// amount, but this is the non-negotiable server-side gate (rules.md §10).
  ///
  /// The minimum applies to the goods subtotal, not the delivery charge —
  /// otherwise a delivery fee could artificially push a sub-minimum cart
  /// over the line.
  Future<void> call(OrderEntity order) async {
    final minimum = Money(AppConstants.kMinOrderAmount);
    if (order.subtotal < minimum) {
      throw MinimumOrderException(orderTotal: order.subtotal, minimumRequired: minimum);
    }
    await _repository.placeOrder(order);
  }
}
