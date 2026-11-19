import '../../../core/constants/app_constants.dart';
import '../../entities/order_entity.dart';
import '../../exceptions/domain_exceptions.dart';
import '../../repositories/order_repository.dart';
import '../../repositories/product_repository.dart';
import '../../value_objects/money.dart';
import 'stock_adjustment.dart';

class PlaceOrderUseCase {
  final OrderRepository _repository;
  final ProductRepository _products;

  PlaceOrderUseCase(this._repository, this._products);

  /// Places [order], enforcing the ₹2,500 minimum order rule one final time
  /// before it's written — the UI must also block checkout below this
  /// amount, but this is the non-negotiable server-side gate (rules.md §10).
  ///
  /// The minimum applies to the goods subtotal, not the delivery charge —
  /// otherwise a delivery fee could artificially push a sub-minimum cart
  /// over the line.
  ///
  /// Every line is re-checked against live stock (the cart may be hours old)
  /// and the ordered quantity is taken out of stock once the order is saved.
  Future<void> call(OrderEntity order) async {
    final minimum = Money(AppConstants.kMinOrderAmount);
    if (order.subtotal < minimum) {
      throw MinimumOrderException(
        orderTotal: order.subtotal,
        minimumRequired: minimum,
      );
    }
    for (final item in order.items) {
      final product = await _products.getProductById(item.productId);
      if (product == null || !product.isActive || !product.isInStock) {
        throw InsufficientStockException(productName: item.name);
      }
      if (item.qty > product.maxQty) {
        throw InsufficientStockException(
          productName: item.name,
          available: product.labelForQty(product.maxQty),
        );
      }
    }
    await _repository.placeOrder(order);
    await adjustStockBestEffort(_products, order.items, direction: -1);
  }
}
