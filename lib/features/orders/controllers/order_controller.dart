import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../domain/entities/order_entity.dart';
import '../../../domain/usecases/order/get_order_history_usecase.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/controllers/auth_state.dart';

final orderHistoryProvider = StreamProvider.autoDispose<List<OrderEntity>>((ref) {
  final authState = ref.watch(authControllerProvider);
  if (authState is! AuthenticatedCustomer) return const Stream.empty();

  final useCase = GetOrderHistoryUseCase(ref.watch(orderRepositoryProvider));
  return useCase(authState.user.uid);
});

/// Derived from the same history stream rather than a separate
/// `getOrderById` repository call — a retailer only ever views their own
/// orders here, and the history stream already has them all.
final orderByIdProvider = Provider.autoDispose.family<AsyncValue<OrderEntity?>, String>((ref, orderId) {
  final history = ref.watch(orderHistoryProvider);
  return history.whenData(
    (orders) => orders.where((o) => o.id == orderId).isEmpty
        ? null
        : orders.firstWhere((o) => o.id == orderId),
  );
});
