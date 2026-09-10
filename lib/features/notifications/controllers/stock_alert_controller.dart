import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../domain/entities/notification_entity.dart';
import '../../../domain/entities/order_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../../orders/controllers/order_controller.dart';

/// Product ids the signed-in retailer has ordered at least
/// [AppConstants.kFrequentOrderThreshold] separate times — derived only from
/// their own order history, never a cross-retailer signal. Empty for admins
/// and signed-out users, since `orderHistoryProvider` is retailer-only.
final frequentlyBoughtProductIdsProvider = Provider.autoDispose<Set<String>>((
  ref,
) {
  final orders =
      ref.watch(orderHistoryProvider).valueOrNull ?? const <OrderEntity>[];
  final counts = <String, int>{};
  for (final order in orders) {
    for (final item in order.items) {
      counts[item.productId] = (counts[item.productId] ?? 0) + 1;
    }
  }
  return counts.entries
      .where((e) => e.value >= AppConstants.kFrequentOrderThreshold)
      .map((e) => e.key)
      .toSet();
});

/// Public — also feeds the retailer Home screen's "Buy Again" rail (Phase
/// 9.7), not just the low-stock check below.
final allActiveProductsProvider =
    StreamProvider.autoDispose<List<ProductEntity>>((ref) {
      return ref.watch(productRepositoryProvider).watchProducts();
    });

/// Frequently-bought products currently at/below the low-stock threshold
/// (including zero) — the set the retailer gets a local heads-up about.
/// Only watches the product stream once there's something to match, so an
/// admin session (empty frequent-id set) never opens a needless listener.
final lowStockFrequentProductsProvider =
    Provider.autoDispose<List<ProductEntity>>((ref) {
      final frequentIds = ref.watch(frequentlyBoughtProductIdsProvider);
      if (frequentIds.isEmpty) return const [];
      final products =
          ref.watch(allActiveProductsProvider).valueOrNull ??
          const <ProductEntity>[];
      return products
          .where(
            (p) =>
                frequentIds.contains(p.id) &&
                p.stock <= AppConstants.kLowStockThreshold,
          )
          .toList();
    });

/// All of the retailer's frequently-bought products, any stock level — the
/// data behind Home's "Buy Again" rail (Phase 9.7). A stricter subset
/// ([lowStockFrequentProductsProvider]) drives the stock-alert notification.
final frequentlyBoughtProductsProvider =
    Provider.autoDispose<List<ProductEntity>>((ref) {
      final frequentIds = ref.watch(frequentlyBoughtProductIdsProvider);
      if (frequentIds.isEmpty) return const [];
      final products =
          ref.watch(allActiveProductsProvider).valueOrNull ??
          const <ProductEntity>[];
      return products.where((p) => frequentIds.contains(p.id)).toList();
    });

/// Watched once from the app root (mirrors `fcmInitializerProvider`).
/// Whenever a product the retailer frequently buys drops to/below the
/// low-stock threshold, writes a one-time local notification into their own
/// notification history — there's no Cloud Function sender in this project
/// (phases.md §5 scope note), so this is an in-app heads-up, not an OS push.
///
/// ponytail: the "already notified" dedupe is an in-memory set, so it resets
/// every app session — a still-low product notifies again after a restart.
/// Move the dedupe key into Hive if that turns out to be noisy in practice.
final stockAlertInitializerProvider = Provider<void>((ref) {
  final notificationRepo = ref.watch(notificationRepositoryProvider);
  final alreadyNotified = <String>{};

  ref.listen(lowStockFrequentProductsProvider, (previous, products) {
    for (final product in products) {
      final key = '${product.id}:${product.stock == 0 ? 'out' : 'low'}';
      if (!alreadyNotified.add(key)) continue;
      notificationRepo.addNotification(
        NotificationEntity(
          id: 'stock_${product.id}_${DateTime.now().microsecondsSinceEpoch}',
          title: product.stock == 0
              ? '${product.name} is out of stock'
              : '${product.name} is running low',
          body: product.stock == 0
              ? 'One of your regulars is currently unavailable.'
              : 'Only ${product.stock} left of one of your regulars — order soon.',
          receivedAt: DateTime.now(),
          isRead: false,
        ),
      );
    }
  }, fireImmediately: true);
});
