import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/weight_formatter.dart';
import '../../../domain/entities/product_entity.dart';
import '../../notifications/controllers/stock_alert_controller.dart';
import 'cart_controller.dart';

const int kMaxGapSuggestions = 6;

/// What one tap on "add" would put in the cart — a round kilo of a weighed
/// product, or one unit of anything else.
double _firstAddPrice(ProductEntity p) =>
    p.priceForQty(p.isWeighed ? defaultAddGrams(p.maxQty) : 1).amount;

/// Products worth showing a retailer who is [gap] ₹ short of the minimum
/// order: in stock, not already in the cart, and with enough stock that
/// buying them could actually close the gap. The retailer's own regulars
/// come first, then whichever product's first add lands closest to the gap.
List<ProductEntity> suggestGapClosers({
  required List<ProductEntity> products,
  required Set<String> cartProductIds,
  required Set<String> frequentIds,
  required double gap,
  int limit = kMaxGapSuggestions,
}) {
  final candidates = products
      .where(
        (p) =>
            p.isInStock &&
            !cartProductIds.contains(p.id) &&
            p.priceForQty(p.maxQty).amount >= gap,
      )
      .toList();

  candidates.sort((a, b) {
    final byRegular =
        (frequentIds.contains(b.id) ? 1 : 0) -
        (frequentIds.contains(a.id) ? 1 : 0);
    if (byRegular != 0) return byRegular;
    final byCloseness = (_firstAddPrice(a) - gap).abs().compareTo(
      (_firstAddPrice(b) - gap).abs(),
    );
    if (byCloseness != 0) return byCloseness;
    return a.name.compareTo(
      b.name,
    ); // List.sort isn't stable — keep it deterministic
  });
  return candidates.take(limit).toList();
}

/// Empty once the cart reaches [AppConstants.kMinOrderAmount].
final cartGapSuggestionsProvider = Provider.autoDispose<List<ProductEntity>>((
  ref,
) {
  final cart = ref.watch(cartControllerProvider);
  final gap = AppConstants.kMinOrderAmount - cart.subtotal.amount;
  if (gap <= 0) return const [];
  return suggestGapClosers(
    products:
        ref.watch(allActiveProductsProvider).valueOrNull ??
        const <ProductEntity>[],
    cartProductIds: {for (final item in cart.items) item.productId},
    frequentIds: ref.watch(frequentlyBoughtProductIdsProvider),
    gap: gap,
  );
});
