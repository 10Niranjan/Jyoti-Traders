import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/core/utils/admin_product_filter.dart';
import 'package:traders_retailer/domain/entities/product_entity.dart';
import 'package:traders_retailer/domain/value_objects/money.dart';

ProductEntity _product({
  required String id,
  required String name,
  String categoryId = 'c1',
  double price = 10,
  int stock = 10,
}) {
  return ProductEntity(
    id: id,
    name: name,
    categoryId: categoryId,
    imageUrl: '',
    price: Money(price),
    unit: ProductUnit.piece,
    stock: stock,
    isActive: true,
  );
}

void main() {
  final rice = _product(
    id: 'p1',
    name: 'Basmati Rice',
    categoryId: 'grains',
    price: 100,
    stock: 40,
  );
  final sugar = _product(
    id: 'p2',
    name: 'White Sugar',
    categoryId: 'staples',
    price: 50,
    stock: 3,
  );
  final oil = _product(
    id: 'p3',
    name: 'Sunflower Oil',
    categoryId: 'staples',
    price: 150,
    stock: 12,
  );

  final products = [rice, sugar, oil];

  test('empty query with no category returns every product, sorted', () {
    final result = filterAndSortAdminProducts(
      products,
      query: '',
      sort: AdminProductSort.nameAsc,
    );
    expect(result.map((p) => p.id), [
      'p1',
      'p3',
      'p2',
    ]); // Basmati, Sunflower, White
  });

  test('query matches by case-insensitive name substring', () {
    final result = filterAndSortAdminProducts(
      products,
      query: 'oil',
      sort: AdminProductSort.nameAsc,
    );
    expect(result.map((p) => p.id), ['p3']);
  });

  test('categoryId filters down to that category only', () {
    final result = filterAndSortAdminProducts(
      products,
      query: '',
      categoryId: 'staples',
      sort: AdminProductSort.nameAsc,
    );
    expect(result.map((p) => p.id), ['p3', 'p2']); // Sunflower, White
  });

  test('stockLowToHigh sorts by stock ascending', () {
    final result = filterAndSortAdminProducts(
      products,
      query: '',
      sort: AdminProductSort.stockLowToHigh,
    );
    expect(result.map((p) => p.id), ['p2', 'p3', 'p1']); // 3, 12, 40
  });

  test('priceLowToHigh and priceHighToLow sort by price', () {
    final lowToHigh = filterAndSortAdminProducts(
      products,
      query: '',
      sort: AdminProductSort.priceLowToHigh,
    );
    expect(lowToHigh.map((p) => p.id), ['p2', 'p1', 'p3']); // 50, 100, 150

    final highToLow = filterAndSortAdminProducts(
      products,
      query: '',
      sort: AdminProductSort.priceHighToLow,
    );
    expect(highToLow.map((p) => p.id), ['p3', 'p1', 'p2']); // 150, 100, 50
  });

  test('query and category filter combine', () {
    final result = filterAndSortAdminProducts(
      products,
      query: 'oil',
      categoryId: 'grains',
      sort: AdminProductSort.nameAsc,
    );
    expect(result, isEmpty);
  });

  test('no match returns an empty list, not an error', () {
    final result = filterAndSortAdminProducts(
      products,
      query: 'zzz',
      sort: AdminProductSort.nameAsc,
    );
    expect(result, isEmpty);
  });
}
