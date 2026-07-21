import '../../entities/order_entity.dart';
import '../../repositories/order_repository.dart';

class UpdateOrderStatusUseCase {
  final OrderRepository _repository;

  UpdateOrderStatusUseCase(this._repository);

  Future<void> call(String orderId, OrderStatus status) {
    return _repository.updateOrderStatus(orderId, status);
  }
}
