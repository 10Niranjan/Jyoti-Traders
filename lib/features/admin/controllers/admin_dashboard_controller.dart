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
