import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/remote/order_remote_datasource.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDatasource _remote;

  OrderRepositoryImpl(this._remote);

  @override
  Future<void> placeOrder(OrderEntity order) {
    return _remote.placeOrder(OrderModel.fromEntity(order));
  }

  @override
  Stream<List<OrderEntity>> watchOrderHistory(String userId) {
    return _remote.watchOrderHistory(userId).map((list) => list.map((m) => m.toEntity()).toList());
  }

  @override
  Stream<List<OrderEntity>> watchAllOrders() {
    return _remote.watchAllOrders().map((list) => list.map((m) => m.toEntity()).toList());
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) {
    return _remote.updateOrderStatus(orderId, status.value);
  }

  @override
  Future<void> recordPaymentClaim(String orderId, {String? screenshotUrl}) {
    return _remote.recordPaymentClaim(orderId, screenshotUrl: screenshotUrl);
  }

  @override
  Future<void> updatePaymentStatus(String orderId, PaymentStatus status) {
    return _remote.updatePaymentStatus(orderId, status.value);
  }
}
