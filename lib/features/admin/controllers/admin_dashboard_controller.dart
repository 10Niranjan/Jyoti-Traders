import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/trend.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../domain/entities/order_entity.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/user/get_pending_users_usecase.dart';
import 'admin_category_controller.dart';
import 'admin_product_controller.dart';

/// Live stream of retailers awaiting approval.
final pendingUsersProvider = StreamProvider.autoDispose<List<UserEntity>>((
  ref,
) {
  final useCase = GetPendingUsersUseCase(ref.watch(userRepositoryProvider));
  return useCase();
});

/// One-time fetch of approved retailers — feeds the "Total Retailers" stat.
final approvedUsersProvider = FutureProvider.autoDispose<List<UserEntity>>((
  ref,
) {
  return ref.watch(userRepositoryProvider).getApprovedUsers();
});

/// Live stream of all orders (newest first, capped at 200 by the repository)
/// — the raw source the dashboard's derived stats/chart are computed from.
final allOrdersProvider = StreamProvider.autoDispose<List<OrderEntity>>((ref) {
  return ref.watch(orderRepositoryProvider).watchAllOrders();
});

/// Derived stat: count of pending approvals.
final pendingApprovalsCountProvider = Provider.autoDispose<AsyncValue<int>>((
  ref,
) {
  return ref.watch(pendingUsersProvider).whenData((users) => users.length);
});

/// Derived stat: count of approved retailers.
final totalRetailersCountProvider = Provider.autoDispose<AsyncValue<int>>((
  ref,
) {
  return ref.watch(approvedUsersProvider).whenData((users) => users.length);
});

/// Derived stat: orders placed today (local calendar day).
final todayOrderCountProvider = Provider.autoDispose<AsyncValue<int>>((ref) {
  return ref.watch(allOrdersProvider).whenData((orders) {
    final now = DateTime.now();
    return orders
        .where(
          (o) =>
              o.createdAt.year == now.year &&
              o.createdAt.month == now.month &&
              o.createdAt.day == now.day,
        )
        .length;
  });
});

/// Derived stat: revenue from today's orders, in whole rupees (cancelled
/// orders excluded — they were never fulfilled).
final todayRevenueProvider = Provider.autoDispose<AsyncValue<int>>((ref) {
  return ref.watch(allOrdersProvider).whenData((orders) {
    final now = DateTime.now();
    final total = orders
        .where(
          (o) =>
              o.orderStatus != OrderStatus.cancelled &&
              o.createdAt.year == now.year &&
              o.createdAt.month == now.month &&
              o.createdAt.day == now.day,
        )
        .fold(0.0, (sum, o) => sum + o.grandTotal.amount);
    return total.round();
  });
});

/// [measure] of today's orders *so far* against the same window last week
/// (midnight to this time of day, seven days back) — so a half-finished day
/// isn't shown as a collapse against a full one. Null when last week's window
/// had nothing to compare to.
double? _todayVsLastWeek(
  List<OrderEntity> orders,
  num Function(Iterable<OrderEntity>) measure,
) {
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  const week = Duration(days: 7);
  Iterable<OrderEntity> within(DateTime start, DateTime end) => orders.where(
    (o) => !o.createdAt.isBefore(start) && !o.createdAt.isAfter(end),
  );
  return trendPercent(
    measure(within(todayStart, now)),
    measure(within(todayStart.subtract(week), now.subtract(week))),
  );
}

/// Trend behind the "Today's Orders" card (counts every order, cancelled
/// included — same as the number it sits under).
final todayOrdersTrendProvider = Provider.autoDispose<AsyncValue<double?>>((
  ref,
) {
  return ref
      .watch(allOrdersProvider)
      .whenData((orders) => _todayVsLastWeek(orders, (os) => os.length));
});

/// Trend behind the "Today's Revenue" card (cancelled orders excluded, same
/// as [todayRevenueProvider]).
final todayRevenueTrendProvider = Provider.autoDispose<AsyncValue<double?>>((
  ref,
) {
  return ref
      .watch(allOrdersProvider)
      .whenData(
        (orders) => _todayVsLastWeek(
          orders,
          (os) => os
              .where((o) => o.orderStatus != OrderStatus.cancelled)
              .fold(0.0, (sum, o) => sum + o.grandTotal.amount),
        ),
      );
});

/// What needs the owner's attention right now — one count per chip on the
/// dashboard's "Needs attention" strip.
class AttentionSummary {
  final int pendingApprovals;

  /// UPI orders where the retailer tapped "I have paid" and the admin hasn't
  /// confirmed the money arrived.
  final int unconfirmedPayments;

  /// Active products at or below `AppConstants.kLowStockThreshold`.
  final int lowStockProducts;

  /// Orders still `pending` after `AppConstants.kUnconfirmedOrderMinutes`.
  final int staleOrders;

  const AttentionSummary({
    required this.pendingApprovals,
    required this.unconfirmedPayments,
    required this.lowStockProducts,
    required this.staleOrders,
  });

  bool get isClear =>
      pendingApprovals == 0 &&
      unconfirmedPayments == 0 &&
      lowStockProducts == 0 &&
      staleOrders == 0;
}

/// Null until all three sources have loaded — the strip shows nothing rather
/// than a false "all caught up" while data is still arriving.
///
/// ponytail: "stale" is judged against `DateTime.now()` when the inputs
/// change, so an order crosses the threshold at the next order/product
/// update rather than the exact minute. Add a periodic tick if that lag ever
/// matters.
final attentionSummaryProvider = Provider.autoDispose<AttentionSummary?>((ref) {
  final pending = ref.watch(pendingUsersProvider).valueOrNull;
  final orders = ref.watch(allOrdersProvider).valueOrNull;
  final products = ref.watch(allProductsProvider).valueOrNull;
  if (pending == null || orders == null || products == null) return null;

  final now = DateTime.now();
  const staleAfter = Duration(minutes: AppConstants.kUnconfirmedOrderMinutes);
  return AttentionSummary(
    pendingApprovals: pending.length,
    unconfirmedPayments: orders
        .where(
          (o) =>
              o.paymentMethod == PaymentMethod.upi &&
              o.paymentStatus == PaymentStatus.paymentClaimed &&
              o.orderStatus != OrderStatus.cancelled,
        )
        .length,
    lowStockProducts: products
        .where((p) => p.isActive && p.stock <= AppConstants.kLowStockThreshold)
        .length,
    staleOrders: orders
        .where(
          (o) =>
              o.orderStatus == OrderStatus.pending &&
              now.difference(o.createdAt) >= staleAfter,
        )
        .length,
  );
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
final topProductsProvider = Provider.autoDispose<AsyncValue<List<TopProduct>>>((
  ref,
) {
  return ref.watch(allOrdersProvider).whenData((orders) {
    final revenueByProduct = <String, double>{};
    final nameByProduct = <String, String>{};

    for (final order in orders) {
      if (order.orderStatus == OrderStatus.cancelled) continue;
      for (final item in order.items) {
        revenueByProduct[item.productId] =
            (revenueByProduct[item.productId] ?? 0) + item.totalPrice.amount;
        nameByProduct[item.productId] ??= item.name;
      }
    }

    final ranked = revenueByProduct.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ranked
        .take(5)
        .map((e) => TopProduct(e.key, nameByProduct[e.key]!, e.value))
        .toList();
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
final last7DaysOrderCountsProvider =
    Provider.autoDispose<AsyncValue<List<DailyOrderCount>>>((ref) {
      return ref.watch(allOrdersProvider).whenData((orders) {
        final today = DateTime.now();
        final todayMidnight = DateTime(today.year, today.month, today.day);
        final days = List.generate(
          7,
          (i) => todayMidnight.subtract(Duration(days: 6 - i)),
        );

        return days.map((day) {
          final count = orders.where((o) {
            final created = o.createdAt;
            return created.year == day.year &&
                created.month == day.month &&
                created.day == day.day;
          }).length;
          return DailyOrderCount(day, count);
        }).toList();
      });
    });

/// One slice of the category-revenue breakdown.
class CategoryRevenue {
  final String categoryId;
  final String categoryName;
  final double revenue;
  const CategoryRevenue(this.categoryId, this.categoryName, this.revenue);
}

/// Derived stat: revenue attributed to each category, by joining order line
/// items (which only carry a productId) against the live product catalog for
/// its categoryId, and the category list for a display name — highest
/// revenue first. A line item whose product has since been deleted is
/// skipped, since there's no category left to attribute it to.
final categoryRevenueProvider =
    Provider.autoDispose<AsyncValue<List<CategoryRevenue>>>((ref) {
      final categoryIdByProduct = {
        for (final p in ref.watch(allProductsProvider).valueOrNull ?? const [])
          p.id: p.categoryId,
      };
      final categoryNameById = {
        for (final c
            in ref.watch(adminCategoriesProvider).valueOrNull ?? const [])
          c.id: c.name,
      };

      return ref.watch(allOrdersProvider).whenData((orders) {
        final revenueByCategory = <String, double>{};
        for (final order in orders) {
          if (order.orderStatus == OrderStatus.cancelled) continue;
          for (final item in order.items) {
            final categoryId = categoryIdByProduct[item.productId];
            if (categoryId == null) continue;
            revenueByCategory[categoryId] =
                (revenueByCategory[categoryId] ?? 0) + item.totalPrice.amount;
          }
        }
        final ranked = revenueByCategory.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        return ranked
            .map(
              (e) => CategoryRevenue(
                e.key,
                categoryNameById[e.key] ?? e.key,
                e.value,
              ),
            )
            .toList();
      });
    });

/// One point in the retailer-growth trend — the cumulative count of
/// approved retailers by the end of [month].
class MonthlyRetailerCount {
  final DateTime month;
  final int cumulativeCount;
  const MonthlyRetailerCount(this.month, this.cumulativeCount);
}

/// Derived stat: cumulative approved-retailer count over the last 6 months —
/// a running total, not a per-month delta, so the line reads as "how big is
/// the retailer base" rather than "how many joined that month."
final retailerGrowthProvider =
    Provider.autoDispose<AsyncValue<List<MonthlyRetailerCount>>>((ref) {
      return ref.watch(approvedUsersProvider).whenData((users) {
        final now = DateTime.now();
        final months = List.generate(
          6,
          (i) => DateTime(now.year, now.month - (5 - i)),
        );
        return months.map((month) {
          final endOfMonth = DateTime(month.year, month.month + 1);
          final count = users
              .where((u) => u.createdAt.isBefore(endOfMonth))
              .length;
          return MonthlyRetailerCount(month, count);
        }).toList();
      });
    });

/// One stage of the order-status funnel — [count] is orders that have
/// *reached at least* this stage, derived from each order's current status
/// rather than a real per-order status history (this app doesn't keep one):
/// status is a linear progression, so an order sitting at "delivered" is
/// known to have passed through every earlier stage already. Cancelled
/// orders are excluded from every stage rather than counted as a "reached
/// pending" data point that never progresses.
class FunnelStage {
  final OrderStatus status;
  final int count;
  const FunnelStage(this.status, this.count);
}

const _funnelProgression = [
  OrderStatus.pending,
  OrderStatus.confirmed,
  OrderStatus.outForDelivery,
  OrderStatus.delivered,
];

final orderStatusFunnelProvider =
    Provider.autoDispose<AsyncValue<List<FunnelStage>>>((ref) {
      return ref.watch(allOrdersProvider).whenData((orders) {
        return _funnelProgression.map((stage) {
          final count = orders
              .where(
                (o) =>
                    o.orderStatus != OrderStatus.cancelled &&
                    o.orderStatus.index >= stage.index,
              )
              .length;
          return FunnelStage(stage, count);
        }).toList();
      });
    });
