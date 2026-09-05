import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/data/repositories/repository_providers.dart';
import 'package:traders_retailer/domain/entities/cart_item_entity.dart';
import 'package:traders_retailer/domain/entities/product_entity.dart';
import 'package:traders_retailer/domain/value_objects/money.dart';
import 'package:traders_retailer/features/cart/screens/cart_screen.dart';
import 'package:traders_retailer/l10n/app_localizations.dart';

import '../helpers/fake_cart_repository.dart';

Widget _wrap(FakeCartRepository repo) => ProviderScope(
      overrides: [cartRepositoryProvider.overrideWithValue(repo)],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CartScreen(),
      ),
    );

void main() {
  testWidgets('shows the empty state when the cart has no items', (tester) async {
    await tester.pumpWidget(_wrap(FakeCartRepository()));
    await tester.pumpAndSettle();

    expect(find.text('Your cart is empty'), findsOneWidget);
  });

  testWidgets('below the ₹2,500 minimum: shows the warning banner and disables checkout', (tester) async {
    final repo = FakeCartRepository([
      CartItemEntity(productId: 'p1', name: 'Rice', imageUrl: '', unitPrice: Money(1000), unit: ProductUnit.box, qty: 1),
    ]);
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    expect(find.textContaining('more to reach the'), findsOneWidget);
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('at or above the ₹2,500 minimum: hides the warning and enables checkout', (tester) async {
    final repo = FakeCartRepository([
      CartItemEntity(productId: 'p1', name: 'Rice', imageUrl: '', unitPrice: Money(1800), unit: ProductUnit.box, qty: 2),
    ]);
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    expect(find.textContaining('more to reach the'), findsNothing);
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNotNull);
  });

  testWidgets('tapping delete removes the item from the cart', (tester) async {
    final repo = FakeCartRepository([
      CartItemEntity(productId: 'p1', name: 'Rice', imageUrl: '', unitPrice: Money(1800), unit: ProductUnit.box, qty: 2),
    ]);
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.pumpAndSettle();

    expect(repo.items, isEmpty);
    expect(find.text('Your cart is empty'), findsOneWidget);
  });

  testWidgets('the qty stepper updates the item quantity', (tester) async {
    final repo = FakeCartRepository([
      CartItemEntity(productId: 'p1', name: 'Rice', imageUrl: '', unitPrice: Money(1800), unit: ProductUnit.box, qty: 2),
    ]);
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    expect(repo.items.single.qty, 3);
  });
}
