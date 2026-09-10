import '../../domain/entities/product_entity.dart';

enum ProductSort { relevance, priceLowToHigh, priceHighToLow }

/// The price used to compare/sort products — a weighed product's `price` is
/// only its small-quantity band rate, not what most customers actually pay,
/// so sorting uses the same "from ₹x/kg" figure (the cheapest band) already
/// shown throughout the UI (`ProductCard`, `_SearchResultTile`, ...).
double _sortPrice(ProductEntity product) =>
    product.isWeighed ? product.rateSlabs!.bestRatePerKg : product.price.amount;

/// Applies [sort] and, if [inStockOnly], drops out-of-stock products —
/// `relevance` (the default) returns [products] exactly as searched/fetched,
/// since that ordering already reflects the underlying query's own ranking.
List<ProductEntity> sortAndFilterProducts(
  List<ProductEntity> products, {
  required ProductSort sort,
  required bool inStockOnly,
}) {
  final filtered = inStockOnly ? products.where((p) => p.isInStock).toList() : List.of(products);

  switch (sort) {
    case ProductSort.relevance:
      return filtered;
    case ProductSort.priceLowToHigh:
      filtered.sort((a, b) => _sortPrice(a).compareTo(_sortPrice(b)));
      return filtered;
    case ProductSort.priceHighToLow:
      filtered.sort((a, b) => _sortPrice(b).compareTo(_sortPrice(a)));
      return filtered;
  }
}
