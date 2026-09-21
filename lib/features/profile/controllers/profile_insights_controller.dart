import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/trend.dart';
import '../../../domain/entities/order_entity.dart';
import '../../home/controllers/home_controller.dart';
import '../../notifications/controllers/stock_alert_controller.dart';
import '../../orders/controllers/order_controller.dart';

/// A product the retailer keeps coming back to, by how many orders held it.
class BoughtProduct {
  final String name;
  final int orders;
  const BoughtProduct(this.name, this.orders);
}

/// The "Your business" card: this month so far against the same stretch of
/// last month, plus what the retailer buys most.
class RetailerInsights {
  final double monthSpend;

  /// Percent change against the same days of last month; null when last month
  /// had nothing to compare to.
  final double? spendTrend;
  final int monthOrders;
  final List<BoughtProduct> topProducts;
  final String? topCategory;

  const RetailerInsights({
    required this.monthSpend,
    required this.spendTrend,
    required this.monthOrders,
    required this.topProducts,
    required this.topCategory,
  });
}

/// Pure so it can be tested without providers. Cancelled orders never count —
/// they were never fulfilled. [now] is a parameter for the same reason.
///
/// Month-to-date is compared with the *same days* of last month (1st to this
/// day/time, clamped for shorter months), not the whole of it — otherwise the
/// 3rd of every month would read as a collapse.
RetailerInsights? computeRetailerInsights(
  List<OrderEntity> orders, {
  required DateTime now,
  Map<String, String> categoryIdByProduct = const {},
  Map<String, String> categoryNameById = const {},
}) {
  final live = orders.where((o) => o.orderStatus != OrderStatus.cancelled);
  if (live.isEmpty) return null;

  final monthStart = DateTime(now.year, now.month);
  final prevMonthStart = DateTime(now.year, now.month - 1);
  final daysInPrevMonth = DateTime(now.year, now.month, 0).day;
  final prevWindowEnd = DateTime(
    now.year,
    now.month - 1,
    now.day < daysInPrevMonth ? now.day : daysInPrevMonth,
    now.hour,
    now.minute,
    now.second,
  );

  Iterable<OrderEntity> within(DateTime start, DateTime end) => live.where(
    (o) => !o.createdAt.isBefore(start) && !o.createdAt.isAfter(end),
  );
  double spend(Iterable<OrderEntity> os) =>
      os.fold(0.0, (sum, o) => sum + o.grandTotal.amount);

  final thisMonth = within(monthStart, now).toList();
  final lastMonthSoFar = within(prevMonthStart, prevWindowEnd);

  // Ranked over the whole loaded history: "what do I buy" is a habit, not a
  // this-month figure. Counted per order, not per quantity — a line can be
  // grams or boxes, which don't add up.
  final ordersByProduct = <String, int>{};
  final nameByProduct = <String, String>{};
  final linesByCategory = <String, int>{};
  for (final order in live) {
    for (final item in order.items) {
      ordersByProduct[item.productId] =
          (ordersByProduct[item.productId] ?? 0) + 1;
      nameByProduct[item.productId] ??= item.name;
      final categoryId = categoryIdByProduct[item.productId];
      if (categoryId != null) {
        linesByCategory[categoryId] = (linesByCategory[categoryId] ?? 0) + 1;
      }
    }
  }

  final ranked = ordersByProduct.entries.toList()
    ..sort((a, b) {
      final byCount = b.value.compareTo(a.value);
      return byCount != 0
          ? byCount
          : nameByProduct[a.key]!.compareTo(nameByProduct[b.key]!);
    });

  final topCategoryId = linesByCategory.entries.isEmpty
      ? null
      : (linesByCategory.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value)))
            .first
            .key;

  final monthSpend = spend(thisMonth);
  return RetailerInsights(
    monthSpend: monthSpend,
    spendTrend: trendPercent(monthSpend, spend(lastMonthSoFar)),
    monthOrders: thisMonth.length,
    topProducts: [
      for (final e in ranked.take(3)) BoughtProduct(nameByProduct[e.key]!, e.value),
    ],
    topCategory: topCategoryId == null ? null : categoryNameById[topCategoryId],
  );
}

/// Null until the retailer has at least one non-cancelled order (the card
/// simply doesn't render for a new shop).
final retailerInsightsProvider = Provider.autoDispose<RetailerInsights?>((ref) {
  final orders = ref.watch(orderHistoryProvider).valueOrNull;
  if (orders == null) return null;
  final products = ref.watch(allActiveProductsProvider).valueOrNull ?? const [];
  final categories = ref.watch(categoriesProvider).valueOrNull ?? const [];
  return computeRetailerInsights(
    orders,
    now: DateTime.now(),
    categoryIdByProduct: {for (final p in products) p.id: p.categoryId},
    categoryNameById: {for (final c in categories) c.id: c.name},
  );
});
