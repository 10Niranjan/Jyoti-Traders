import '../../domain/entities/product_entity.dart';

enum AdminProductSort {
  nameAsc,
  stockLowToHigh,
  priceLowToHigh,
  priceHighToLow,
}

/// Same "compare on the cheapest band" rule `product_sort.dart` uses for
/// retailer search — a weighed product's flat `price` is only its
/// small-quantity band rate, not a representative figure to sort by.
double _sortPrice(ProductEntity product) =>
    product.isWeighed ? product.rateSlabs!.bestRatePerKg : product.price.amount;

/// Admin catalog search/filter/sort — name substring match (case-insensitive),
/// an optional category filter, then a sort. Kept separate from retailer
/// search's `ProductSort` (`product_sort.dart`): the two enums serve
/// different audiences (an admin managing stock vs. a retailer buying), and
/// admin's stock-first sort has no equivalent on the retailer side.
List<ProductEntity> filterAndSortAdminProducts(
  List<ProductEntity> products, {
  required String query,
  String? categoryId,
  required AdminProductSort sort,
}) {
  final trimmedQuery = query.trim().toLowerCase();
  var filtered = trimmedQuery.isEmpty
      ? List.of(products)
      : products
            .where((p) => p.name.toLowerCase().contains(trimmedQuery))
            .toList();
  if (categoryId != null) {
    filtered = filtered.where((p) => p.categoryId == categoryId).toList();
  }

  switch (sort) {
    case AdminProductSort.nameAsc:
      filtered.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    case AdminProductSort.stockLowToHigh:
      filtered.sort((a, b) => a.stock.compareTo(b.stock));
    case AdminProductSort.priceLowToHigh:
      filtered.sort((a, b) => _sortPrice(a).compareTo(_sortPrice(b)));
    case AdminProductSort.priceHighToLow:
      filtered.sort((a, b) => _sortPrice(b).compareTo(_sortPrice(a)));
  }
  return filtered;
}
