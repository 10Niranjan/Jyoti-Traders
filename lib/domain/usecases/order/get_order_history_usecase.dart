import '../../entities/order_entity.dart';
import '../../repositories/order_repository.dart';

class GetOrderHistoryUseCase {
  final OrderRepository _repository;

  GetOrderHistoryUseCase(this._repository);

  Stream<List<OrderEntity>> call(String userId) {
    return _repository.watchOrderHistory(userId);
  }
}
