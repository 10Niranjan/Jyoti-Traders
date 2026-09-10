import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/data/repositories/repository_providers.dart';
import 'package:traders_retailer/domain/entities/product_entity.dart';
import 'package:traders_retailer/domain/repositories/product_repository.dart';
import 'package:traders_retailer/domain/value_objects/money.dart';
import 'package:traders_retailer/features/admin/screens/manage_products_screen.dart';
import 'package:traders_retailer/l10n/app_localizations.dart';

class FakeProductRepository implements ProductRepository {
  final List<ProductEntity> products;
  final List<String> deletedIds = [];
  final List<ProductEntity> updated = [];

  FakeProductRepository(this.products);

  @override
  Stream<List<ProductEntity>> watchAllProducts() => Stream.value(products);

  @override
  Stream<List<ProductEntity>> watchProducts({String? categoryId}) =>
      Stream.value(products.where((p) => p.isActive).toList());

  @override
  Future<List<ProductEntity>> searchProducts(String query) async => [];

  @override
  Future<ProductEntity?> getProductById(String productId) async => null;

  @override
  Future<void> createProduct(ProductEntity product) async {}

  @override
  Future<void> updateProduct(ProductEntity product) async =>
      updated.add(product);

  @override
  Future<void> deleteProduct(String productId) async =>
      deletedIds.add(productId);
}

ProductEntity _product({
  required String id,
  required String name,
  int stock = 20,
  bool isActive = true,
}) => ProductEntity(
  id: id,
  name: name,
  categoryId: 'cat_grains',
  imageUrl: '',
  price: Money(250),
  unit: ProductUnit.kg,
  stock: stock,
  isActive: isActive,
);

Widget _wrap(FakeProductRepository repo) => ProviderScope(
  overrides: [productRepositoryProvider.overrideWithValue(repo)],
  child: const MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: ManageProductsScreen(),
  ),
);

void main() {
  testWidgets('shows an empty state when the catalog has no products', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(FakeProductRepository([])));
    await tester.pumpAndSettle();

    expect(find.text('No products yet'), findsOneWidget);
  });

  testWidgets('lists products with price, unit and stock', (tester) async {
    await tester.pumpWidget(
      _wrap(FakeProductRepository([_product(id: 'p1', name: 'Basmati Rice')])),
    );
    await tester.pumpAndSettle();

    expect(find.text('Basmati Rice'), findsOneWidget);
    expect(find.text('₹250 · per kg'), findsOneWidget);
    expect(find.text('Stock: 20'), findsOneWidget);
  });

  testWidgets(
    'shows inactive products too — the admin must be able to re-activate them',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          FakeProductRepository([
            _product(id: 'p1', name: 'Active Product'),
            _product(id: 'p2', name: 'Hidden Product', isActive: false),
          ]),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Active Product'), findsOneWidget);
      expect(find.text('Hidden Product'), findsOneWidget);
      expect(
        find.text('Inactive'),
        findsOneWidget,
      ); // badge only on the inactive one
    },
  );

  testWidgets('flags low stock with a banner and a per-row warning', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        FakeProductRepository([
          _product(id: 'p1', name: 'Plenty', stock: 40),
          _product(id: 'p2', name: 'Running Out', stock: 3),
        ]),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1 product is low on stock (≤ 5).'), findsOneWidget);
    expect(
      find.byIcon(Icons.warning_amber_rounded),
      findsNWidgets(2),
    ); // banner + the low row
  });

  testWidgets(
    'does not show the low-stock banner when everything is well stocked',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          FakeProductRepository([
            _product(id: 'p1', name: 'Plenty', stock: 40),
          ]),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
    },
  );

  testWidgets(
    'delete asks for confirmation first and only deletes when confirmed',
    (tester) async {
      final repo = FakeProductRepository([
        _product(id: 'p1', name: 'Basmati Rice'),
      ]);
      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Delete product?'), findsOneWidget);

      // Backing out must not delete anything.
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(repo.deletedIds, isEmpty);

      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(repo.deletedIds, ['p1']);
      expect(find.text('Basmati Rice deleted.'), findsOneWidget);
    },
  );

  testWidgets(
    'bulk edit: selecting products and setting stock updates every checked product',
    (tester) async {
      final repo = FakeProductRepository([
        _product(id: 'p1', name: 'Basmati Rice', stock: 40),
        _product(id: 'p2', name: 'White Sugar', stock: 22),
      ]);
      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Select'));
      await tester.pumpAndSettle();
      expect(find.byType(Checkbox), findsNWidgets(2));

      // Only check the first product — the second must stay untouched.
      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();
      expect(find.text('1 selected'), findsOneWidget);

      await tester.tap(find.text('Bulk Edit'));
      await tester.pumpAndSettle();
      expect(find.text('Bulk edit 1 products'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Set stock to'),
        '99',
      );
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      expect(repo.updated, hasLength(1));
      expect(repo.updated.single.id, 'p1');
      expect(repo.updated.single.stock, 99);
      expect(find.text('1 of 1 products updated.'), findsOneWidget);
      // Selection mode exits automatically after a successful bulk edit.
      expect(find.byType(Checkbox), findsNothing);
    },
  );
}
