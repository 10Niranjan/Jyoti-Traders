import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../domain/entities/order_entity.dart';
import '../../../domain/usecases/order/update_order_status_usecase.dart';
import '../../../domain/usecases/order/update_payment_status_usecase.dart';
import 'admin_dashboard_controller.dart' show allOrdersProvider;

/// Single order for the management screen, derived from the same
/// `allOrdersProvider` stream the dashboard's stats already watch — an
/// admin always arrives here from a list already backed by that stream.
final adminOrderByIdProvider = Provider.autoDispose.family<AsyncValue<OrderEntity?>, String>((ref, orderId) {
  return ref.watch(allOrdersProvider).whenData(
        (orders) {
          final idx = orders.indexWhere((o) => o.id == orderId);
          return idx == -1 ? null : orders[idx];
        },
      );
});

class AdminOrderController extends StateNotifier<AsyncValue<void>> {
  final UpdateOrderStatusUseCase _updateStatusUseCase;
  final UpdatePaymentStatusUseCase _updatePaymentStatusUseCase;

  AdminOrderController(this._updateStatusUseCase, this._updatePaymentStatusUseCase)
      : super(const AsyncValue.data(null));

  Future<bool> updateStatus(String orderId, OrderStatus status) async {
    state = const AsyncValue.loading();
    try {
      await _updateStatusUseCase(orderId, status);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> markAsPaid(String orderId) async {
    state = const AsyncValue.loading();
    try {
      await _updatePaymentStatusUseCase(orderId, PaymentStatus.paid);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final adminOrderControllerProvider =
    StateNotifierProvider.autoDispose<AdminOrderController, AsyncValue<void>>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return AdminOrderController(UpdateOrderStatusUseCase(repository), UpdatePaymentStatusUseCase(repository));
});
