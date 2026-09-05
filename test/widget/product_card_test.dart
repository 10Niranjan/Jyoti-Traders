import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/data/repositories/repository_providers.dart';
import 'package:traders_retailer/domain/entities/cart_item_entity.dart';
import 'package:traders_retailer/domain/entities/product_entity.dart';
import 'package:traders_retailer/domain/value_objects/money.dart';
import 'package:traders_retailer/l10n/app_localizations.dart';
import 'package:traders_retailer/shared/widgets/product_card.dart';

import '../helpers/fake_cart_repository.dart';

ProductEntity _product({int stock = 20, bool isActive = true}) => ProductEntity(
      id: 'p1',
      name: 'Basmati Rice 25kg',
      categoryId: 'cat_grains',
      imageUrl: '',
      price: Money(1800),
      unit: ProductUnit.box,
      stock: stock,
      isActive: isActive,
    );

// Constrained to a realistic grid-cell width — in production this card only
// ever renders inside a `GridView` cell (childAspectRatio 0.68), never at
// unconstrained width, which would blow the `AspectRatio(1.1)` image out to
// the full test surface's height.
Widget _wrap(FakeCartRepository repo, ProductEntity product) => ProviderScope(
      overrides: [cartRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SizedBox(width: 170, child: ProductCard(product: product, onTap: () {})),
        ),
      ),
    );

void main() {
  testWidgets('shows an ADD pill when the product is not in the cart', (tester) async {
    await tester.pumpWidget(_wrap(FakeCartRepository(), _product()));
    await tester.pumpAndSettle();

    expect(find.text('ADD'), findsOneWidget);
    expect(find.byIcon(Icons.remove_rounded), findsNothing);
  });

  testWidgets('tapping ADD opens the quantity sheet, and confirming it switches to a stepper', (tester) async {
    final repo = FakeCartRepository();
    await tester.pumpWidget(_wrap(repo, _product()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('ADD'));
    await tester.pumpAndSettle();

    // Nothing lands in the cart until the sheet is confirmed.
    expect(repo.items, isEmpty);

    await tester.tap(find.text('5 box')); // preset chip
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add 5 box to Cart'));
    await tester.pumpAndSettle();

    expect(repo.items, hasLength(1));
    expect(repo.items.single.qty, 5);
    expect(find.text('5'), findsOneWidget);
    expect(find.byIcon(Icons.remove_rounded), findsOneWidget);
  });

  testWidgets('stepper increments and decrements, removing the item at zero', (tester) async {
    final repo = FakeCartRepository([
      CartItemEntity(productId: 'p1', name: 'Basmati Rice 25kg', imageUrl: '', unitPrice: Money(1800), unit: ProductUnit.box, qty: 2),
    ]);
    await tester.pumpWidget(_wrap(repo, _product()));
    await tester.pumpAndSettle();

    expect(find.text('2'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    expect(find.text('3'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.remove_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.remove_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.remove_rounded));
    await tester.pumpAndSettle();

    expect(repo.items, isEmpty);
    expect(find.byIcon(Icons.remove_rounded), findsNothing);
    expect(find.text('ADD'), findsOneWidget); // back to the add pill
  });

  testWidgets('out-of-stock products show a disabled control and no add happens', (tester) async {
    final repo = FakeCartRepository();
    await tester.pumpWidget(_wrap(repo, _product(stock: 0)));
    await tester.pumpAndSettle();

    expect(find.text('Out of stock'), findsOneWidget);

    await tester.tap(find.text('ADD'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(repo.items, isEmpty);
  });
}
