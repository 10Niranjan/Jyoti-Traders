import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/usecases/category/get_categories_usecase.dart';
import '../../notifications/controllers/stock_alert_controller.dart'
    show allActiveProductsProvider;
import '../../../domain/entities/order_entity.dart';
import '../../orders/controllers/order_controller.dart';

/// The retailer's most recent order that's still in progress (pending,
/// confirmed or out for delivery) — the data behind Home's live-order strip.
/// Derived from the history stream the Orders tab already watches; null when
/// nothing is in flight, so the strip simply doesn't render.
final activeOrderProvider = Provider.autoDispose<OrderEntity?>((ref) {
  final orders =
      ref.watch(orderHistoryProvider).valueOrNull ?? const <OrderEntity>[];
  OrderEntity? latest;
  for (final order in orders) {
    final inProgress = switch (order.orderStatus) {
      OrderStatus.pending ||
      OrderStatus.confirmed ||
      OrderStatus.outForDelivery => true,
      OrderStatus.delivered || OrderStatus.cancelled => false,
    };
    if (inProgress &&
        (latest == null || order.createdAt.isAfter(latest.createdAt))) {
      latest = order;
    }
  }
  return latest;
});

/// Retailer-facing category list — active only. Admin's equivalent,
/// `adminCategoriesProvider`, watches the same unfiltered stream since it
/// needs to show (and re-activate) inactive categories too.
final categoriesProvider = StreamProvider.autoDispose<List<CategoryEntity>>((
  ref,
) {
  final useCase = GetCategoriesUseCase(ref.watch(categoryRepositoryProvider));
  return useCase().map((list) => list.where((c) => c.isActive).toList());
});

/// Admin-curated products (`ProductEntity.isTopProduct`) for Home's "Top
/// Products" section — derived from the same product stream every other
/// Home rail already watches, not a new repository call. Named distinctly
/// from the admin dashboard's own `topProductsProvider` (revenue-ranked
/// analytics, a different `TopProduct` type entirely) to avoid confusion.
final homeTopProductsProvider = Provider.autoDispose<List<ProductEntity>>((
  ref,
) {
  final products =
      ref.watch(allActiveProductsProvider).valueOrNull ??
      const <ProductEntity>[];
  return products.where((p) => p.isTopProduct).toList();
});
