import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/repositories/wishlist_repository.dart';
import '../../notifications/controllers/stock_alert_controller.dart' show allActiveProductsProvider;

class WishlistController extends StateNotifier<Set<String>> {
  final WishlistRepository _repository;
  StreamSubscription<Set<String>>? _subscription;

  WishlistController(this._repository) : super(const {}) {
    _subscription = _repository.watchWishlist().listen((ids) => state = ids);
  }

  Future<void> toggle(String productId) => _repository.toggle(productId);

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final wishlistControllerProvider = StateNotifierProvider<WishlistController, Set<String>>((ref) {
  final repository = ref.watch(wishlistRepositoryProvider);
  return WishlistController(repository);
});

/// The wishlisted products themselves — joins the id set above with the
/// live catalog, same "derive from an existing stream" pattern as
/// `frequentlyBoughtProductsProvider`. A product removed from the catalog
/// (or deactivated) simply drops out here without needing any cleanup of
/// the wishlist itself.
final wishlistProductsProvider = Provider.autoDispose<List<ProductEntity>>((ref) {
  final ids = ref.watch(wishlistControllerProvider);
  if (ids.isEmpty) return const [];
  final products = ref.watch(allActiveProductsProvider).valueOrNull ?? const <ProductEntity>[];
  return products.where((p) => ids.contains(p.id)).toList();
});
