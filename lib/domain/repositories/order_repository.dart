import '../entities/order_entity.dart';

abstract class OrderRepository {
  Future<void> placeOrder(OrderEntity order);

  Stream<List<OrderEntity>> watchOrderHistory(String userId);

  Stream<List<OrderEntity>> watchAllOrders();

  Future<void> updateOrderStatus(String orderId, OrderStatus status);
}
