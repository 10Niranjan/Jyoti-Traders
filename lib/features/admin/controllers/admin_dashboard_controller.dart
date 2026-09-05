import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../domain/entities/order_entity.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/user/get_pending_users_usecase.dart';

/// Live stream of retailers awaiting approval.
final pendingUsersProvider = StreamProvider.autoDispose<List<UserEntity>>((ref) {
  final useCase = GetPendingUsersUseCase(ref.watch(userRepositoryProvider));
  return useCase();
});

/// One-time fetch of approved retailers — feeds the "Total Retailers" stat.
final approvedUsersProvider = FutureProvider.autoDispose<List<UserEntity>>((ref) {
  return ref.watch(userRepositoryProvider).getApprovedUsers();
});

/// Live stream of all orders (newest first, capped at 200 by the repository)
/// — the raw source the dashboard's derived stats/chart are computed from.
final allOrdersProvider = StreamProvider.autoDispose<List<OrderEntity>>((ref) {
  return ref.watch(orderRepositoryProvider).watchAllOrders();
});

/// Derived stat: count of pending approvals.
final pendingApprovalsCountProvider = Provider.autoDispose<AsyncValue<int>>((ref) {
  return ref.watch(pendingUsersProvider).whenData((users) => users.length);
});

/// Derived stat: count of approved retailers.
final totalRetailersCountProvider = Provider.autoDispose<AsyncValue<int>>((ref) {
  return ref.watch(approvedUsersProvider).whenData((users) => users.length);
});

/// Derived stat: orders placed today (local calendar day).
final todayOrderCountProvider = Provider.autoDispose<AsyncValue<int>>((ref) {
  return ref.watch(allOrdersProvider).whenData((orders) {
    final now = DateTime.now();
    return orders.where((o) =>
        o.createdAt.year == now.year && o.createdAt.month == now.month && o.createdAt.day == now.day).length;
  });
});

/// Derived stat: revenue from today's orders, in whole rupees (cancelled
/// orders excluded — they were never fulfilled).
final todayRevenueProvider = Provider.autoDispose<AsyncValue<int>>((ref) {
  return ref.watch(allOrdersProvider).whenData((orders) {
    final now = DateTime.now();
    final total = orders
        .where((o) =>
            o.orderStatus != OrderStatus.cancelled &&
            o.createdAt.year == now.year &&
            o.createdAt.month == now.month &&
            o.createdAt.day == now.day)
        .fold(0.0, (sum, o) => sum + o.grandTotal.amount);
    return total.round();
  });
});

/// One row in the "Top Products" list — revenue-ranked, not quantity-ranked,
/// since order lines mix per-piece counts and per-kg grams that can't be
/// summed meaningfully.
class TopProduct {
  final String productId;
  final String name;
  final double revenue;
  const TopProduct(this.productId, this.name, this.revenue);
}

/// Derived stat: the 5 best-selling products by revenue across the loaded
/// order history (cancelled orders excluded).
final topProductsProvider = Provider.autoDispose<AsyncValue<List<TopProduct>>>((ref) {
  return ref.watch(allOrdersProvider).whenData((orders) {
    final revenueByProduct = <String, double>{};
    final nameByProduct = <String, String>{};

    for (final order in orders) {
      if (order.orderStatus == OrderStatus.cancelled) continue;
      for (final item in order.items) {
        revenueByProduct[item.productId] = (revenueByProduct[item.productId] ?? 0) + item.totalPrice.amount;
        nameByProduct[item.productId] ??= item.name;
      }
    }

    final ranked = revenueByProduct.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ranked.take(5).map((e) => TopProduct(e.key, nameByProduct[e.key]!, e.value)).toList();
  });
});

/// One bucket in the last-7-days order chart.
class DailyOrderCount {
  final DateTime day;
  final int count;
  const DailyOrderCount(this.day, this.count);
}

/// Derived stat: order counts bucketed by day for the last 7 days
/// (oldest first, so index 0 renders as the chart's leftmost bar).
final last7DaysOrderCountsProvider = Provider.autoDispose<AsyncValue<List<DailyOrderCount>>>((ref) {
  return ref.watch(allOrdersProvider).whenData((orders) {
    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);
    final days = List.generate(7, (i) => todayMidnight.subtract(Duration(days: 6 - i)));

    return days.map((day) {
      final count = orders.where((o) {
        final created = o.createdAt;
        return created.year == day.year && created.month == day.month && created.day == day.day;
      }).length;
      return DailyOrderCount(day, count);
    }).toList();
  });
});
