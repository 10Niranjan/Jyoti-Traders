import '../../entities/order_entity.dart';
import '../../repositories/order_repository.dart';
import '../../repositories/product_repository.dart';
import 'stock_adjustment.dart';

class UpdateOrderStatusUseCase {
  final OrderRepository _repository;
  final ProductRepository _products;

  UpdateOrderStatusUseCase(this._repository, this._products);

  /// Cancelling an order puts its stock back on the shelf; moving a
  /// cancelled order back to an active status takes it again.
  Future<void> call(OrderEntity order, OrderStatus status) async {
    await _repository.updateOrderStatus(order.id, status);
    final wasCancelled = order.orderStatus == OrderStatus.cancelled;
    final isCancelled = status == OrderStatus.cancelled;
    if (wasCancelled != isCancelled) {
      await adjustStockBestEffort(
        _products,
        order.items,
        direction: isCancelled ? 1 : -1,
      );
    }
  }
}
