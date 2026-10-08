import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/analytics_service.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../domain/entities/order_entity.dart';
import '../../../domain/exceptions/domain_exceptions.dart';
import '../../../domain/usecases/order/place_order_usecase.dart';
import '../../cart/controllers/cart_controller.dart';

/// `AsyncValue<String?>` holds the placed order's id on success — the
/// standard error-handling pattern from rules.md §7.
class CheckoutController extends StateNotifier<AsyncValue<String?>> {
  final PlaceOrderUseCase _placeOrderUseCase;
  final CartController _cartController;
  final AnalyticsService _analytics;

  CheckoutController(this._placeOrderUseCase, this._cartController, [AnalyticsService? analytics])
      : _analytics = analytics ?? AnalyticsService(),
        super(const AsyncValue.data(null));

  Future<void> placeOrder(OrderEntity order) async {
    state = const AsyncValue.loading();
    try {
      await _placeOrderUseCase(order);
      await _cartController.clearCart();
      state = AsyncValue.data(order.id);
      _analytics.logOrderPlaced(
        orderId: order.id,
        value: order.grandTotal.amount,
        paymentMethod: order.paymentMethod.name,
      );
    } on MinimumOrderException catch (e, st) {
      state = AsyncValue.error(e, st);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void reset() => state = const AsyncValue.data(null);
}

final checkoutControllerProvider =
    StateNotifierProvider.autoDispose<CheckoutController, AsyncValue<String?>>((ref) {
  final useCase = PlaceOrderUseCase(ref.watch(orderRepositoryProvider));
  final cartController = ref.watch(cartControllerProvider.notifier);
  return CheckoutController(useCase, cartController);
});
