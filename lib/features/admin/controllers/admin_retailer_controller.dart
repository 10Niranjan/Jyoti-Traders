import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/value_objects/money.dart';
import 'admin_dashboard_controller.dart';

/// An approved retailer plus their lifetime order count and total spend.
class RetailerSummary {
  final UserEntity user;
  final int orderCount;
  final Money totalSpend;

  const RetailerSummary({required this.user, required this.orderCount, required this.totalSpend});
}

/// Approved retailers with order count/total spend, derived client-side
/// from the same `approvedUsersProvider`/`allOrdersProvider` streams the
/// dashboard's own stats already use — no new repository query needed.
/// Sorted by total spend, highest first.
final retailerSummariesProvider = Provider.autoDispose<AsyncValue<List<RetailerSummary>>>((ref) {
  final usersAsync = ref.watch(approvedUsersProvider);
  final ordersAsync = ref.watch(allOrdersProvider);

  return usersAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
    data: (users) => ordersAsync.when(
      loading: () => const AsyncValue.loading(),
      error: (e, st) => AsyncValue.error(e, st),
      data: (orders) {
        final summaries = users.map((user) {
          final userOrders = orders.where((o) => o.userId == user.uid);
          final totalSpend = userOrders.fold(Money.zero, (sum, o) => sum + o.grandTotal);
          return RetailerSummary(user: user, orderCount: userOrders.length, totalSpend: totalSpend);
        }).toList()
          ..sort((a, b) => b.totalSpend.amount.compareTo(a.totalSpend.amount));
        return AsyncValue.data(summaries);
      },
    ),
  );
});
