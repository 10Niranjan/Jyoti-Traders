import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:traders_retailer/data/repositories/repository_providers.dart';
import 'package:traders_retailer/domain/entities/cart_item_entity.dart';
import 'package:traders_retailer/domain/entities/category_entity.dart';
import 'package:traders_retailer/domain/entities/product_entity.dart';
import 'package:traders_retailer/domain/repositories/category_repository.dart';
import 'package:traders_retailer/domain/repositories/product_repository.dart';
import 'package:traders_retailer/domain/value_objects/money.dart';
import 'package:traders_retailer/features/products/screens/category_products_screen.dart';
import 'package:traders_retailer/l10n/app_localizations.dart';
import 'package:traders_retailer/shared/widgets/product_card.dart';

import '../helpers/fake_cart_repository.dart';

class MockProductRepository extends Mock implements ProductRepository {}

class MockCategoryRepository extends Mock implements CategoryRepository {}

const _grains = CategoryEntity(
  id: 'c1',
  name: 'Grains',
  iconUrl: '',
  displayOrder: 0,
  isActive: true,
);
const _oils = CategoryEntity(
  id: 'c2',
  name: 'Oils',
  iconUrl: '',
  displayOrder: 1,
  isActive: true,
);

ProductEntity _product(
  String id,
  String name,
  String categoryId, {
  int stock = 20,
}) => ProductEntity(
  id: id,
  name: name,
  categoryId: categoryId,
  imageUrl: '',
  price: Money(1800),
  unit: ProductUnit.box,
  stock: stock,
  isActive: true,
);

Widget _screen(List<CategoryEntity> categories, List<ProductEntity> products) {
  final productRepo = MockProductRepository();
  when(
    () => productRepo.watchProducts(categoryId: any(named: 'categoryId')),
  ).thenAnswer((invocation) {
    final id = invocation.namedArguments[#categoryId] as String?;
    return Stream.value(
      products.where((p) => id == null || p.categoryId == id).toList(),
    );
  });
  final categoryRepo = MockCategoryRepository();
  when(
    categoryRepo.watchCategories,
  ).thenAnswer((_) => Stream.value(categories));

  return ProviderScope(
    overrides: [
      productRepositoryProvider.overrideWithValue(productRepo),
      categoryRepositoryProvider.overrideWithValue(categoryRepo),
      cartRepositoryProvider.overrideWithValue(FakeCartRepository()),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: CategoryProductsScreen(categoryId: 'c1'),
    ),
  );
}

/// A real phone width (360 dp) — the rail layout only leaves ~130 dp per card
/// there, which is the case that has to fit.
void _usePhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(360 * 3, 800 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

void main() {
  group('category rail', () {
    testWidgets('lists every category and switches products in place', (
      tester,
    ) async {
      _usePhoneViewport(tester);
      await tester.pumpWidget(
        _screen(
          [_grains, _oils],
          [
            _product('p1', 'Basmati Rice', 'c1'),
            _product('p2', 'Sunflower Oil', 'c2'),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Opened on Grains: its product is showing, Oils' is not.
      expect(find.text('Basmati Rice'), findsOneWidget);
      expect(find.text('Sunflower Oil'), findsNothing);
      // Both categories are in the rail (Grains also titles the app bar).
      expect(find.text('Oils'), findsOneWidget);

      await tester.tap(find.text('Oils'));
      await tester.pumpAndSettle();

      expect(find.text('Sunflower Oil'), findsOneWidget);
      expect(find.text('Basmati Rice'), findsNothing);
      // App bar follows the selection (title + the rail entry).
      expect(find.text('Oils'), findsNWidgets(2));
    });

    testWidgets('a lone category shows no rail', (tester) async {
      _usePhoneViewport(tester);
      await tester.pumpWidget(
        _screen([_grains], [_product('p1', 'Basmati Rice', 'c1')]),
      );
      await tester.pumpAndSettle();

      expect(find.text('Basmati Rice'), findsOneWidget);
      // Only the app bar title — no second "Grains" from a rail entry.
      expect(find.text('Grains'), findsOneWidget);
    });
  });

  // Every place a ProductCard is boxed: the rail grid at 360 dp (~132 wide),
  // the "You may also like" rail (150), and the full-width grid (~158). The
  // box height is what `productCardHeight` hands the real grids, so this is
  // the actual production constraint — at each text size the app offers.
  group('product card fits the height the grids give it', () {
    Widget card(
      ProductEntity product, {
      required double width,
      FakeCartRepository? cart,
      double textScale = 1.0,
    }) => ProviderScope(
      overrides: [
        cartRepositoryProvider.overrideWithValue(cart ?? FakeCartRepository()),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: Builder(
              builder: (context) => SizedBox(
                width: width,
                height: productCardHeight(context, width),
                child: ProductCard(product: product, onTap: () {}),
              ),
            ),
          ),
        ),
      ),
    );

    const longName = 'Basmati Rice Premium Long Grain 25kg';

    // The stepper's entrance animation starts a zero-length timer from inside
    // LayoutBuilder's layout pass; one extra pump lets it fire before the
    // test ends.
    Future<void> settle(WidgetTester tester) async {
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
    }

    for (final width in [132.0, 150.0, 158.0]) {
      for (final scale in [0.9, 1.0, 1.2, 1.3]) {
        final label = '${width.toInt()} dp at ${scale}x text';

        testWidgets('ADD state, $label', (tester) async {
          await tester.pumpWidget(
            card(
              _product('p1', longName, 'c1'),
              width: width,
              textScale: scale,
            ),
          );
          await settle(tester);

          expect(tester.takeException(), isNull); // no RenderFlex overflow
          expect(find.text('ADD'), findsOneWidget);
          expect(find.text('₹1,800'), findsOneWidget); // price not truncated
        });

        testWidgets('in-cart stepper state, $label', (tester) async {
          final cart = FakeCartRepository([
            CartItemEntity(
              productId: 'p1',
              name: longName,
              imageUrl: '',
              unitPrice: Money(1800),
              unit: ProductUnit.box,
              qty: 12,
            ),
          ]);
          await tester.pumpWidget(
            card(
              _product('p1', longName, 'c1'),
              width: width,
              cart: cart,
              textScale: scale,
            ),
          );
          await settle(tester);

          expect(tester.takeException(), isNull);
          expect(find.text('12'), findsOneWidget);
          expect(find.text('₹1,800'), findsOneWidget);
        });

        testWidgets('out-of-stock state, $label', (tester) async {
          await tester.pumpWidget(
            card(
              _product('p1', longName, 'c1', stock: 0),
              width: width,
              textScale: scale,
            ),
          );
          await settle(tester);

          expect(tester.takeException(), isNull);
          expect(find.text('Out of stock'), findsOneWidget);
        });
      }
    }
  });
}
