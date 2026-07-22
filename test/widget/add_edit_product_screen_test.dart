import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/data/repositories/repository_providers.dart';
import 'package:traders_retailer/domain/entities/category_entity.dart';
import 'package:traders_retailer/domain/entities/product_entity.dart';
import 'package:traders_retailer/domain/repositories/category_repository.dart';
import 'package:traders_retailer/domain/repositories/product_repository.dart';
import 'package:traders_retailer/domain/value_objects/money.dart';
import 'package:traders_retailer/features/admin/screens/add_edit_product_screen.dart';

import '../helpers/test_viewport.dart';

class FakeCategoryRepository implements CategoryRepository {
  @override
  Stream<List<CategoryEntity>> watchCategories() => Stream.value(const [
        CategoryEntity(id: 'cat_grains', name: 'Atta, Rice & Grains', iconUrl: '', displayOrder: 1, isActive: true),
        CategoryEntity(id: 'cat_oils', name: 'Edible Oils', iconUrl: '', displayOrder: 2, isActive: true),
      ]);

  @override
  Future<void> createCategory(CategoryEntity category) async {}

  @override
  Future<void> updateCategory(CategoryEntity category) async {}

  @override
  Future<void> deleteCategory(String categoryId) async {}
}

class FakeProductRepository implements ProductRepository {
  final List<ProductEntity> products;
  final List<ProductEntity> created = [];
  final List<ProductEntity> updated = [];

  FakeProductRepository([this.products = const []]);

  @override
  Stream<List<ProductEntity>> watchAllProducts() => Stream.value(products);

  @override
  Stream<List<ProductEntity>> watchProducts({String? categoryId}) => Stream.value(products);

  @override
  Future<List<ProductEntity>> searchProducts(String query) async => [];

  @override
  Future<ProductEntity?> getProductById(String productId) async => null;

  @override
  Future<void> createProduct(ProductEntity product) async => created.add(product);

  @override
  Future<void> updateProduct(ProductEntity product) async => updated.add(product);

  @override
  Future<void> deleteProduct(String productId) async {}
}

Widget _wrap(FakeProductRepository productRepo, {String? productId}) => ProviderScope(
      overrides: [
        productRepositoryProvider.overrideWithValue(productRepo),
        categoryRepositoryProvider.overrideWithValue(FakeCategoryRepository()),
      ],
      child: MaterialApp(home: AddEditProductScreen(productId: productId)),
    );

void main() {
  // This form is taller than the default 800x600 test surface, which would
  // otherwise leave the submit button outside the hit-testable area.
  useTallTestViewport();

  testWidgets('create mode shows an empty "Add Product" form', (tester) async {
    await tester.pumpWidget(_wrap(FakeProductRepository()));
    await tester.pumpAndSettle();

    expect(find.text('Add Product'), findsNWidgets(2)); // app bar + submit button
    expect(find.widgetWithText(TextFormField, 'Basmati Rice'), findsNothing);
  });

  testWidgets('blocks submission when required fields are empty', (tester) async {
    final repo = FakeProductRepository();
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Add Product'));
    await tester.pumpAndSettle();

    expect(find.text('Product name is required'), findsOneWidget);
    expect(repo.created, isEmpty);
  });

  testWidgets('rejects a zero or negative price', (tester) async {
    final repo = FakeProductRepository();
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Product name'), 'Test Product');
    await tester.enterText(find.widgetWithText(TextFormField, 'Price (₹)'), '0');
    await tester.enterText(find.widgetWithText(TextFormField, 'Stock quantity'), '10');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add Product'));
    await tester.pumpAndSettle();

    expect(find.text('Price must be above ₹0'), findsOneWidget);
    expect(repo.created, isEmpty);
  });

  testWidgets('creates a product from valid form input', (tester) async {
    final repo = FakeProductRepository();
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Product name'), 'Basmati Rice 25kg');
    await tester.enterText(find.widgetWithText(TextFormField, 'Price (₹)'), '2250');
    await tester.enterText(find.widgetWithText(TextFormField, 'Stock quantity'), '40');

    await tester.tap(find.text('Category'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edible Oils').last);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Add Product'));
    await tester.pumpAndSettle();

    expect(repo.created, hasLength(1));
    final saved = repo.created.single;
    expect(saved.name, 'Basmati Rice 25kg');
    expect(saved.price, Money(2250));
    expect(saved.stock, 40);
    expect(saved.categoryId, 'cat_oils');
    expect(saved.isActive, isTrue);
    expect(saved.id, isNotEmpty); // generated
  });

  testWidgets('edit mode pre-fills the form from the existing product and updates it', (tester) async {
    final existing = ProductEntity(
      id: 'p1',
      name: 'Sunflower Oil 15L',
      categoryId: 'cat_oils',
      imageUrl: '',
      price: Money(1800),
      unit: ProductUnit.litre,
      stock: 12,
      description: 'Refined',
      isActive: true,
    );
    final repo = FakeProductRepository([existing]);

    await tester.pumpWidget(_wrap(repo, productId: 'p1'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Product'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Sunflower Oil 15L'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '12'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'Sunflower Oil 15L'), 'Sunflower Oil 15L (New)');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Save Changes'));
    await tester.pumpAndSettle();

    expect(repo.updated, hasLength(1));
    expect(repo.updated.single.id, 'p1'); // keeps its id rather than creating a duplicate
    expect(repo.updated.single.name, 'Sunflower Oil 15L (New)');
    expect(repo.created, isEmpty);
  });
}
