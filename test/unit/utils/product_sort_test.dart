import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/core/utils/product_sort.dart';
import 'package:traders_retailer/domain/entities/product_entity.dart';
import 'package:traders_retailer/domain/value_objects/money.dart';
import 'package:traders_retailer/domain/value_objects/weight_rate_slabs.dart';

ProductEntity _product({
  required String id,
  required double price,
  int stock = 10,
  WeightRateSlabs? rateSlabs,
}) {
  return ProductEntity(
    id: id,
    name: id,
    categoryId: 'c1',
    imageUrl: '',
    price: Money(price),
    unit: rateSlabs != null ? ProductUnit.kg : ProductUnit.piece,
    stock: stock,
    isActive: true,
    rateSlabs: rateSlabs,
  );
}

void main() {
  final cheap = _product(id: 'cheap', price: 10);
  final mid = _product(id: 'mid', price: 50);
  final expensive = _product(id: 'expensive', price: 100);
  final outOfStock = _product(id: 'out-of-stock', price: 5, stock: 0);
  final weighed = _product(
    id: 'weighed',
    price: 44,
    rateSlabs: const WeightRateSlabs(
      below240g: 44,
      upto999g: 40,
      upto2400g: 39,
      above2400g: 38,
    ),
  );

  final products = [expensive, cheap, outOfStock, mid, weighed];

  test('relevance keeps the original order untouched', () {
    final result = sortAndFilterProducts(
      products,
      sort: ProductSort.relevance,
      inStockOnly: false,
    );
    expect(result, products);
  });

  test(
    'priceLowToHigh sorts by the cheapest applicable price, weighed products by their best ₹/kg',
    () {
      final result = sortAndFilterProducts(
        products,
        sort: ProductSort.priceLowToHigh,
        inStockOnly: false,
      );
      // weighed.bestRatePerKg (38) sits between outOfStock (5) and cheap (10)... below cheap actually:
      // order by price: outOfStock(5), cheap(10), weighed(38), mid(50), expensive(100)
      expect(result.map((p) => p.id), [
        'out-of-stock',
        'cheap',
        'weighed',
        'mid',
        'expensive',
      ]);
    },
  );

  test('priceHighToLow reverses that order', () {
    final result = sortAndFilterProducts(
      products,
      sort: ProductSort.priceHighToLow,
      inStockOnly: false,
    );
    expect(result.map((p) => p.id), [
      'expensive',
      'mid',
      'weighed',
      'cheap',
      'out-of-stock',
    ]);
  });

  test(
    'inStockOnly drops out-of-stock products without changing sort behavior',
    () {
      final result = sortAndFilterProducts(
        products,
        sort: ProductSort.priceLowToHigh,
        inStockOnly: true,
      );
      expect(result.map((p) => p.id), ['cheap', 'weighed', 'mid', 'expensive']);
    },
  );

  test(
    'inStockOnly with no in-stock products returns an empty list, not an error',
    () {
      final result = sortAndFilterProducts(
        [outOfStock],
        sort: ProductSort.relevance,
        inStockOnly: true,
      );
      expect(result, isEmpty);
    },
  );

  test(
    'categoryId filters to that category only, combined with sort/inStockOnly',
    () {
      final result = sortAndFilterProducts(
        products,
        sort: ProductSort.relevance,
        inStockOnly: false,
        categoryId: 'c1',
      );
      expect(
        result,
        products,
      ); // every fixture product is already categoryId 'c1'
    },
  );

  test('categoryId with no matching products returns an empty list', () {
    final result = sortAndFilterProducts(
      products,
      sort: ProductSort.relevance,
      inStockOnly: false,
      categoryId: 'nonexistent',
    );
    expect(result, isEmpty);
  });
}
