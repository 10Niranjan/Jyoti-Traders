import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/data/repositories/repository_providers.dart';
import 'package:traders_retailer/domain/entities/cart_item_entity.dart';
import 'package:traders_retailer/domain/entities/product_entity.dart';
import 'package:traders_retailer/domain/value_objects/money.dart';
import 'package:traders_retailer/domain/value_objects/weight_rate_slabs.dart';
import 'package:traders_retailer/features/cart/controllers/cart_controller.dart';
import 'package:traders_retailer/shared/widgets/quantity_sheet.dart';

import '../helpers/fake_cart_repository.dart';

/// Stock is counted in kilos for a weighed product, so `stock: 5` is a 5 kg
/// (5000 g) ceiling.
ProductEntity _weighed({int stock = 5}) => ProductEntity(
      id: 'p1',
      name: 'Toor Dal',
      categoryId: 'cat_pulses',
      imageUrl: '',
      price: Money(44),
      unit: ProductUnit.kg,
      stock: stock,
      isActive: true,
      rateSlabs: WeightRateSlabs.defaults,
    );

/// The `Consumer` is not decoration: `cartControllerProvider` fills from a
/// stream, so its very first reader sees an empty cart for one microtask. In
/// the app the shell's nav bar has been watching it since launch, and this
/// keeps the test on that same footing rather than making the sheet the
/// provider's first reader.
Widget _wrap(FakeCartRepository repo, ProductEntity product) => ProviderScope(
      overrides: [cartRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(
        home: Scaffold(
          body: Consumer(
            builder: (context, ref, _) {
              ref.watch(cartControllerProvider);
              return ElevatedButton(
                onPressed: () => showQuantitySheet(context, product),
                child: const Text('open'),
              );
            },
          ),
        ),
      ),
    );

Future<void> _openSheet(WidgetTester tester) async {
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a typed weight is read as kilos and stored as grams', (tester) async {
    final repo = FakeCartRepository();
    await tester.pumpWidget(_wrap(repo, _weighed()));
    await _openSheet(tester);

    await tester.enterText(find.byType(TextField), '2.5');
    await tester.pumpAndSettle();

    expect(find.text('Add 2.5 kg to Cart'), findsOneWidget);

    await tester.tap(find.text('Add 2.5 kg to Cart'));
    await tester.pumpAndSettle();

    expect(repo.items.single.qty, 2500);
  });

  testWidgets('a typed quantity above stock is capped at what is in stock', (tester) async {
    final repo = FakeCartRepository();
    await tester.pumpWidget(_wrap(repo, _weighed(stock: 5)));
    await _openSheet(tester);

    await tester.enterText(find.byType(TextField), '99');
    await tester.pumpAndSettle();

    // The button label is the contract here — it always states the amount
    // that will actually be ordered, even when the field still reads 99.
    await tester.tap(find.text('Add 5 kg to Cart'));
    await tester.pumpAndSettle();

    expect(repo.items.single.qty, 5000);
  });

  testWidgets('below the minimum the sheet refuses to add', (tester) async {
    final repo = FakeCartRepository();
    await tester.pumpWidget(_wrap(repo, _weighed()));
    await _openSheet(tester);

    await tester.enterText(find.byType(TextField), '0.05'); // 50 g, min is 100 g
    await tester.pumpAndSettle();

    expect(find.text('Minimum 100 g'), findsOneWidget);
    await tester.tap(find.text('Enter a quantity'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(repo.items, isEmpty);
  });

  testWidgets('re-opening for a line already in the cart sets the quantity instead of summing it', (tester) async {
    final repo = FakeCartRepository([
      CartItemEntity(
        productId: 'p1',
        name: 'Toor Dal',
        imageUrl: '',
        unitPrice: Money(44),
        unit: ProductUnit.kg,
        qty: 2000,
        rateSlabs: WeightRateSlabs.defaults,
      ),
    ]);
    await tester.pumpWidget(_wrap(repo, _weighed()));
    await _openSheet(tester);

    // Seeded from the cart, so the sheet opens on the line's current weight.
    expect(find.text('Update to 2 kg'), findsOneWidget);

    await tester.tap(find.text('1 kg')); // preset chip
    await tester.pumpAndSettle();
    await tester.tap(find.text('Update to 1 kg'));
    await tester.pumpAndSettle();

    expect(repo.items.single.qty, 1000);
  });
}
