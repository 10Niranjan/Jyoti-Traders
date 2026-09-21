import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/data/models/user_model.dart';
import 'package:traders_retailer/data/repositories/auth_repository_provider.dart';
import 'package:traders_retailer/data/repositories/repository_providers.dart';
import 'package:traders_retailer/domain/entities/cart_item_entity.dart';
import 'package:traders_retailer/domain/entities/product_entity.dart';
import 'package:traders_retailer/domain/value_objects/money.dart';
import 'package:traders_retailer/features/admin/controllers/admin_delivery_config_controller.dart';
import 'package:traders_retailer/features/cart/screens/cart_screen.dart';
import 'package:traders_retailer/features/notifications/controllers/stock_alert_controller.dart';
import 'package:traders_retailer/l10n/app_localizations.dart';

import '../helpers/fake_auth_repository.dart';
import '../helpers/fake_cart_repository.dart';
import '../helpers/test_viewport.dart';

final _retailer = UserModel(
  uid: 'u1',
  name: 'Ramesh',
  email: 'ramesh@test.com',
  phone: '9876543210',
  role: UserRole.customer,
  status: UserStatus.approved,
  businessName: 'Ramesh Kirana Store',
  createdAt: DateTime(2026, 1, 1),
);

// No coordinates on the retailer's address, so `resolveDeliveryCharge` falls
// back to the flat placeholder — none of the assertions below depend on its
// exact value, only on `cart.subtotal` (the ₹2,500 minimum gating).
Widget _wrap(
  FakeCartRepository repo, {
  List<ProductEntity> catalogue = const [],
}) => ProviderScope(
  overrides: [
    cartRepositoryProvider.overrideWithValue(repo),
    authRepositoryProvider.overrideWithValue(FakeAuthRepository(_retailer)),
    deliveryConfigProvider.overrideWith((ref) => const Stream.empty()),
    allActiveProductsProvider.overrideWith((ref) => Stream.value(catalogue)),
    frequentlyBoughtProductIdsProvider.overrideWithValue(const {}),
  ],
  child: const MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: CartScreen(),
  ),
);

ProductEntity _product(
  String id,
  String name,
  double price, {
  int stock = 10,
}) => ProductEntity(
  id: id,
  name: name,
  categoryId: 'c1',
  imageUrl: '',
  price: Money(price),
  unit: ProductUnit.box,
  stock: stock,
  isActive: true,
);

CartItemEntity _riceLine(double price) => CartItemEntity(
  productId: 'rice',
  name: 'Rice',
  imageUrl: '',
  unitPrice: Money(price),
  unit: ProductUnit.box,
  qty: 1,
);

void main() {
  useTallTestViewport();

  testWidgets('shows the empty state when the cart has no items', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(FakeCartRepository()));
    await tester.pumpAndSettle();

    expect(find.text('Your cart is empty'), findsOneWidget);
  });

  testWidgets(
    'below the ₹2,500 minimum: shows the warning banner and disables checkout',
    (tester) async {
      final repo = FakeCartRepository([
        CartItemEntity(
          productId: 'p1',
          name: 'Rice',
          imageUrl: '',
          unitPrice: Money(1000),
          unit: ProductUnit.box,
          qty: 1,
        ),
      ]);
      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();

      expect(find.textContaining('more to reach the'), findsOneWidget);
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    },
  );

  testWidgets(
    'at or above the ₹2,500 minimum: hides the warning and enables checkout',
    (tester) async {
      final repo = FakeCartRepository([
        CartItemEntity(
          productId: 'p1',
          name: 'Rice',
          imageUrl: '',
          unitPrice: Money(1800),
          unit: ProductUnit.box,
          qty: 2,
        ),
      ]);
      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();

      expect(find.textContaining('more to reach the'), findsNothing);
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
    },
  );

  testWidgets('tapping delete removes the item from the cart', (tester) async {
    final repo = FakeCartRepository([
      CartItemEntity(
        productId: 'p1',
        name: 'Rice',
        imageUrl: '',
        unitPrice: Money(1800),
        unit: ProductUnit.box,
        qty: 2,
      ),
    ]);
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.pumpAndSettle();

    expect(repo.items, isEmpty);
    expect(find.text('Your cart is empty'), findsOneWidget);
  });

  testWidgets('swiping a line away removes it and Undo brings it back', (
    tester,
  ) async {
    final repo = FakeCartRepository([
      CartItemEntity(
        productId: 'p1',
        name: 'Rice',
        imageUrl: '',
        unitPrice: Money(1800),
        unit: ProductUnit.box,
        qty: 2,
      ),
    ]);
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.drag(find.text('Rice'), const Offset(-600, 0));
    await tester.pumpAndSettle();

    expect(repo.items, isEmpty);
    expect(
      tester.takeException(),
      isNull,
    ); // no "still part of the tree" assert
    expect(find.text('Rice removed'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(repo.items, hasLength(1));
    expect(repo.items.single.productId, 'p1');
    expect(repo.items.single.qty, 2);
  });

  testWidgets('the delete button also offers Undo', (tester) async {
    final repo = FakeCartRepository([
      CartItemEntity(
        productId: 'p1',
        name: 'Rice',
        imageUrl: '',
        unitPrice: Money(1800),
        unit: ProductUnit.box,
        qty: 2,
      ),
    ]);
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(repo.items.single.qty, 2);
  });

  testWidgets('the qty stepper updates the item quantity', (tester) async {
    final repo = FakeCartRepository([
      CartItemEntity(
        productId: 'p1',
        name: 'Rice',
        imageUrl: '',
        unitPrice: Money(1800),
        unit: ProductUnit.box,
        qty: 2,
      ),
    ]);
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    expect(repo.items.single.qty, 3);
  });

  group('minimum-order nudge', () {
    testWidgets(
      'below the minimum: shows a progress bar and suggestions that are not already in the cart',
      (tester) async {
        final repo = FakeCartRepository([_riceLine(1000)]);
        await tester.pumpWidget(
          _wrap(
            repo,
            catalogue: [
              _product('rice', 'Rice', 1000), // already in the cart
              _product('oil', 'Sunflower Oil', 1600),
              _product('tiny', 'Matchbox', 5, stock: 3), // cannot close the gap
            ],
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(LinearProgressIndicator), findsOneWidget);
        expect(find.text('Suggested to reach ₹2,500'), findsOneWidget);
        expect(find.text('Sunflower Oil'), findsOneWidget);
        expect(find.text('Matchbox'), findsNothing);
        // "Rice" is the cart line only — not repeated as a suggestion.
        expect(find.text('Rice'), findsOneWidget);
      },
    );

    testWidgets('at the minimum: no suggestions are shown', (tester) async {
      final repo = FakeCartRepository([_riceLine(2600)]);
      await tester.pumpWidget(
        _wrap(repo, catalogue: [_product('oil', 'Sunflower Oil', 1600)]),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sunflower Oil'), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('adding a suggestion closes the gap and clears the nudge', (
      tester,
    ) async {
      final repo = FakeCartRepository([_riceLine(1000)]);
      await tester.pumpWidget(
        _wrap(repo, catalogue: [_product('oil', 'Sunflower Oil', 1600)]),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('ADD'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byWidgetPredicate(
          (w) =>
              w is Text && RegExp(r'^Add .* to Cart$').hasMatch(w.data ?? ''),
        ),
      );
      await tester.pumpAndSettle();

      expect(repo.items.map((i) => i.productId), containsAll(['rice', 'oil']));
      // ₹1,000 + ₹1,600 = ₹2,600 — over the minimum, so the nudge is gone
      // and the suggestion has moved up into the cart list.
      expect(find.textContaining('more to reach the'), findsNothing);
      expect(find.text('Suggested to reach ₹2,500'), findsNothing);
    });
  });
}
