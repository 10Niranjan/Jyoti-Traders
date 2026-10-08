import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/data/repositories/repository_providers.dart';
import 'package:traders_retailer/domain/entities/category_entity.dart';
import 'package:traders_retailer/domain/entities/product_entity.dart';
import 'package:traders_retailer/domain/repositories/category_repository.dart';
import 'package:traders_retailer/domain/repositories/product_repository.dart';
import 'package:traders_retailer/domain/value_objects/money.dart';
import 'package:traders_retailer/features/admin/screens/catalog_screen.dart';
import 'package:traders_retailer/l10n/app_localizations.dart';

class FakeProductRepository implements ProductRepository {
  final List<ProductEntity> products;
  FakeProductRepository(this.products);

  @override
  Stream<List<ProductEntity>> watchAllProducts() => Stream.value(products);

  @override
  Stream<List<ProductEntity>> watchProducts({String? categoryId}) =>
      Stream.value(products);

  @override
  Future<List<ProductEntity>> searchProducts(String query) async => [];

  @override
  Future<ProductEntity?> getProductById(String productId) async => null;

  @override
  Future<void> createProduct(ProductEntity product) async {}

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

ProductEntity _product({required String id, required String name}) =>
    ProductEntity(
      id: id,
      name: name,
      categoryId: 'c1',
      imageUrl: '',
      price: Money(250),
      unit: ProductUnit.kg,
      stock: 20,
      isActive: true,
    );

CategoryEntity _category({required String id, required String name}) =>
    CategoryEntity(
      id: id,
      name: name,
      iconUrl: '',
      displayOrder: 0,
      isActive: true,
    );

Widget _wrap({
  List<ProductEntity> products = const [],
  List<CategoryEntity> categories = const [],
}) => ProviderScope(
  overrides: [
    productRepositoryProvider.overrideWithValue(
      FakeProductRepository(products),
    ),
    categoryRepositoryProvider.overrideWithValue(
      FakeCategoryRepository(categories),
    ),
  ],
  child: const MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: CatalogScreen(),
  ),
);

void main() {
  testWidgets('opens on the Products segment with the Add Product FAB', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        products: [_product(id: 'p1', name: 'Basmati Rice')],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Basmati Rice'), findsOneWidget);
    expect(find.text('Add Product'), findsOneWidget);
    expect(find.text('Add Category'), findsNothing);
  });

  testWidgets(
    'switching to the Categories tab shows categories and the Add Category FAB',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          products: [_product(id: 'p1', name: 'Basmati Rice')],
          categories: [_category(id: 'c1', name: 'Grains')],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Categories'));
      await tester.pumpAndSettle();

      expect(find.text('Grains'), findsOneWidget);
      expect(find.text('Add Category'), findsOneWidget);
      expect(find.text('Add Product'), findsNothing);
    },
  );

  testWidgets('shows the empty state for an empty catalog on both segments', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.text('No products yet'), findsOneWidget);

    await tester.tap(find.text('Categories'));
    await tester.pumpAndSettle();

    expect(find.text('No categories yet'), findsOneWidget);
  });

  testWidgets('the Bulk Import action only shows on the Products segment', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.upload_file_outlined), findsOneWidget);

    await tester.tap(find.text('Categories'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.upload_file_outlined), findsNothing);
  });
}
