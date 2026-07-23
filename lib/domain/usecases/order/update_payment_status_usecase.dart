import '../../entities/order_entity.dart';
import '../../repositories/order_repository.dart';

/// Admin-only: manually confirms (or reverses) a UPI payment.
class UpdatePaymentStatusUseCase {
  final OrderRepository _repository;

  UpdatePaymentStatusUseCase(this._repository);

  Future<void> call(String orderId, PaymentStatus status) {
    return _repository.updatePaymentStatus(orderId, status);
  }
}
