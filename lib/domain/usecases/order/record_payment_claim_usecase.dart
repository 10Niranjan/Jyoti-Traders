import '../../repositories/order_repository.dart';

/// The retailer's "I have paid" confirmation on the UPI payment screen.
class RecordPaymentClaimUseCase {
  final OrderRepository _repository;

  RecordPaymentClaimUseCase(this._repository);

  Future<void> call(String orderId, {String? screenshotUrl}) {
    return _repository.recordPaymentClaim(orderId, screenshotUrl: screenshotUrl);
  }
}
