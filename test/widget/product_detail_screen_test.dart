import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/data/repositories/repository_providers.dart';
import 'package:traders_retailer/domain/entities/product_entity.dart';
import 'package:traders_retailer/domain/repositories/product_repository.dart';
import 'package:traders_retailer/domain/repositories/wishlist_repository.dart';
import 'package:traders_retailer/domain/value_objects/money.dart';
import 'package:traders_retailer/features/products/screens/product_detail_screen.dart';
import 'package:traders_retailer/l10n/app_localizations.dart';

import '../helpers/fake_cart_repository.dart';
import '../helpers/test_viewport.dart';

class FakeProductRepository implements ProductRepository {
  final Map<String, ProductEntity> products;
  FakeProductRepository(this.products);

  @override
  Stream<List<ProductEntity>> watchProducts({String? categoryId}) =>
      Stream.value(products.values.where((p) => categoryId == null || p.categoryId == categoryId).toList());

  @override
  Stream<List<ProductEntity>> watchAllProducts() => watchProducts();

  @override
  Future<List<ProductEntity>> searchProducts(String query) async => [];

  @override
  Future<ProductEntity?> getProductById(String productId) async => products[productId];

  @override
  Future<void> createProduct(ProductEntity product) async {}

  @override
  Future<void> updateProduct(ProductEntity product) async {}

  @override
  Future<void> deleteProduct(String productId) async {}
}

class FakeWishlistRepository implements WishlistRepository {
  Set<String> ids;
  FakeWishlistRepository([this.ids = const {}]);

  @override
  Stream<Set<String>> watchWishlist() => Stream.value(ids);

  @override
  Future<void> toggle(String productId) async {
    ids = {...ids};
    if (!ids.remove(productId)) ids.add(productId);
  }
}

ProductEntity _product({required String id, required String name, String categoryId = 'c1'}) => ProductEntity(
  id: id,
  name: name,
  categoryId: categoryId,
  imageUrl: '',
  price: Money(500),
  unit: ProductUnit.box,
  stock: 10,
  isActive: true,
);

Widget _wrap(Map<String, ProductEntity> products, {String productId = 'p1'}) => ProviderScope(
  overrides: [
    productRepositoryProvider.overrideWithValue(FakeProductRepository(products)),
    cartRepositoryProvider.overrideWithValue(FakeCartRepository()),
    wishlistRepositoryProvider.overrideWithValue(FakeWishlistRepository()),
  ],
  child: MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: ProductDetailScreen(productId: productId),
  ),
);

void main() {
  useTallTestViewport();

  testWidgets('shows a "You may also like" rail with other products from the same category', (tester) async {
    await tester.pumpWidget(
      _wrap({
        'p1': _product(id: 'p1', name: 'Basmati Rice'),
        'p2': _product(id: 'p2', name: 'Sona Masoori Rice'),
        'p3': _product(id: 'p3', name: 'Sunflower Oil', categoryId: 'c2'),
      }),
    );
    await tester.pumpAndSettle();

    expect(find.text('You may also like'), findsOneWidget);
    expect(find.text('Sona Masoori Rice'), findsOneWidget);
  });

  testWidgets('excludes the current product from its own recommendations', (tester) async {
    await tester.pumpWidget(
      _wrap({
        'p1': _product(id: 'p1', name: 'Basmati Rice'),
        'p2': _product(id: 'p2', name: 'Sona Masoori Rice'),
      }),
    );
    await tester.pumpAndSettle();

    // "Basmati Rice" appears once, as the page's own title — not a
    // second time inside the rail.
    expect(find.text('Basmati Rice'), findsOneWidget);
  });

  testWidgets('shows no rail when no other product shares the category', (tester) async {
    await tester.pumpWidget(_wrap({'p1': _product(id: 'p1', name: 'Basmati Rice')}));
    await tester.pumpAndSettle();

    expect(find.text('You may also like'), findsNothing);
  });
}
