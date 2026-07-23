import '../entities/order_entity.dart';

abstract class OrderRepository {
  Future<void> placeOrder(OrderEntity order);

  Stream<List<OrderEntity>> watchOrderHistory(String userId);

  Stream<List<OrderEntity>> watchAllOrders();

  Future<void> updateOrderStatus(String orderId, OrderStatus status);

  /// The retailer's "I have paid" confirmation on the UPI payment screen —
  /// moves [PaymentStatus] to `paymentClaimed` and optionally attaches the
  /// uploaded payment screenshot, in one write.
  Future<void> recordPaymentClaim(String orderId, {String? screenshotUrl});

  /// Admin-only: manually confirms a UPI payment (or reverses one).
  Future<void> updatePaymentStatus(String orderId, PaymentStatus status);
}
