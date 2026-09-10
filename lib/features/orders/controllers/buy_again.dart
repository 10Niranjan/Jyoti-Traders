import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../domain/entities/cart_item_entity.dart';
import '../../../domain/entities/order_entity.dart';
import '../../cart/controllers/cart_controller.dart';

class BuyAgainResult {
  final int added;
  final int unavailable;

  const BuyAgainResult({required this.added, required this.unavailable});
}

/// Re-adds every line of [order] to the cart, re-priced off the *live*
/// product (never the order's frozen price — a reorder is a new cart line,
/// not a copy of an old invoice). Shared by `OrderDetailScreen`'s action row
/// and `OrderHistoryScreen`'s per-row reorder button so this repricing logic
/// only lives in one place.
Future<BuyAgainResult> buyAgainItems(WidgetRef ref, OrderEntity order) async {
  final productRepo = ref.read(productRepositoryProvider);
  final cart = ref.read(cartControllerProvider.notifier);
  var added = 0;
  var unavailable = 0;

  for (final item in order.items) {
    final product = await productRepo.getProductById(item.productId);
    if (product == null || !product.isActive || !product.isInStock) {
      unavailable++;
      continue;
    }
    final qty = item.qty > product.maxQty ? product.maxQty : item.qty;
    await cart.addItem(
      CartItemEntity(
        productId: product.id,
        name: product.name,
        imageUrl: product.imageUrl,
        unitPrice: product.price,
        unit: product.unit,
        qty: qty,
        rateSlabs: product.rateSlabs,
      ),
    );
    added++;
  }

  return BuyAgainResult(added: added, unavailable: unavailable);
}
