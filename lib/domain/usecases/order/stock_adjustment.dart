import '../../entities/order_item_entity.dart';
import '../../repositories/product_repository.dart';

/// Moves stock for every line of an order: [direction] -1 takes it (order
/// placed), +1 puts it back (order cancelled). Rounded to whole grams so
/// repeated part-kilo orders can't drift, and never below zero. A product
/// deleted since the order was placed is skipped — there's nothing to adjust.
///
/// ponytail: read-modify-write per product, not atomic — two retailers
/// checking out the last unit at the same instant could both pass. Move this
/// into a Firestore transaction (or FieldValue.increment) once the live
/// Firebase project is connected. Orders placed before stock tracking existed
/// never took stock, so an admin cancelling one of those adds a little back.
Future<void> adjustStockForItems(
  ProductRepository products,
  List<OrderItemEntity> items, {
  required int direction,
}) async {
  for (final item in items) {
    final product = await products.getProductById(item.productId);
    if (product == null) continue;
    final next =
        ((product.stock + direction * item.stockQty) * 1000).round() / 1000;
    await products.updateProduct(product.copyWith(stock: next < 0 ? 0 : next));
  }
}

/// [adjustStockForItems] for callers that have *already* saved the order or
/// status change. That write is the source of truth: if the stock write then
/// fails, reporting the whole action as failed would make the retailer place
/// the same order again (or leave the admin retrying a done cancel).
/// ponytail: the failure is dropped silently — the domain layer has no
/// logger; surface it once stock moves server-side.
Future<void> adjustStockBestEffort(
  ProductRepository products,
  List<OrderItemEntity> items, {
  required int direction,
}) async {
  try {
    await adjustStockForItems(products, items, direction: direction);
  } catch (_) {}
}
