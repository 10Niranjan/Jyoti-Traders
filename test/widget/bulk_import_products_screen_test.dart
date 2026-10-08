import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/data/repositories/repository_providers.dart';
import 'package:traders_retailer/domain/entities/category_entity.dart';
import 'package:traders_retailer/domain/entities/product_entity.dart';
import 'package:traders_retailer/domain/repositories/category_repository.dart';
import 'package:traders_retailer/domain/repositories/product_repository.dart';
import 'package:traders_retailer/features/admin/screens/bulk_import_products_screen.dart';
import 'package:traders_retailer/l10n/app_localizations.dart';

import '../helpers/test_viewport.dart';

class FakeProductRepository implements ProductRepository {
  final List<ProductEntity> created = [];

  @override
  Stream<List<ProductEntity>> watchAllProducts() => Stream.value(created);

  @override
  Stream<List<ProductEntity>> watchProducts({String? categoryId}) =>
      Stream.value(created);

  @override
  Future<List<ProductEntity>> searchProducts(String query) async => [];

  @override
  Future<ProductEntity?> getProductById(String productId) async => null;

  @override
  Future<void> createProduct(ProductEntity product) async =>
      created.add(product);

  @override
  Future<void> updateProduct(ProductEntity product) async {}

  @override
  Future<void> deleteProduct(String productId) async {}
}

class FakeCategoryRepository implements CategoryRepository {
  final List<CategoryEntity> categories;
  FakeCategoryRepository(this.categories);

  @override
  Stream<List<CategoryEntity>> watchCategories() => Stream.value(categories);

  @override
  Future<void> createCategory(CategoryEntity category) async {}

  @override
  Future<void> updateCategory(CategoryEntity category) async {}

  @override
  Future<void> deleteCategory(String categoryId) async {}
}

Widget _wrap(FakeProductRepository productRepo) => ProviderScope(
  overrides: [
    productRepositoryProvider.overrideWithValue(productRepo),
    categoryRepositoryProvider.overrideWithValue(
      FakeCategoryRepository([
        const CategoryEntity(
          id: 'c1',
          name: 'Rice',
          iconUrl: '',
          displayOrder: 0,
          isActive: true,
        ),
      ]),
    ),
  ],
  child: const MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: BulkImportProductsScreen(),
  ),
);

void main() {
  useTallTestViewport();

  testWidgets('previewing valid CSV shows a row per product and enables Import', (
    tester,
  ) async {
    final repo = FakeProductRepository();
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField).first,
      'name,category,price,unit,stock,description\nBasmati Rice 25kg,Rice,1800,box,10,Premium',
    );
    await tester.pump();
    await tester.tap(find.text('Preview'));
    await tester.pumpAndSettle();

    expect(find.text('Basmati Rice 25kg'), findsOneWidget);
    expect(find.text('Import 1'), findsOneWidget);
  });

  testWidgets('an invalid row is flagged and excluded from the import count', (
    tester,
  ) async {
    final repo = FakeProductRepository();
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField).first,
      'name,category,price,unit,stock,description\nBad Row,Wheat,1800,box,10,',
    );
    await tester.pump();
    await tester.tap(find.text('Preview'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Unknown category'), findsOneWidget);
    expect(find.text('Import 0'), findsOneWidget);
  });

  testWidgets('tapping Import creates the valid products and shows a summary', (
    tester,
  ) async {
    final repo = FakeProductRepository();
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField).first,
      'name,category,price,unit,stock,description\nBasmati Rice 25kg,Rice,1800,box,10,Premium',
    );
    await tester.pump();
    await tester.tap(find.text('Preview'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Import 1'));
    await tester.pumpAndSettle();

    expect(repo.created, hasLength(1));
    expect(repo.created.single.name, 'Basmati Rice 25kg');
    expect(find.text('1 product(s) created.'), findsOneWidget);
  });
}
