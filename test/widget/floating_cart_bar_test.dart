import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/domain/entities/cart_entity.dart';
import 'package:traders_retailer/domain/entities/cart_item_entity.dart';
import 'package:traders_retailer/domain/entities/product_entity.dart';
import 'package:traders_retailer/domain/value_objects/money.dart';
import 'package:traders_retailer/shared/widgets/floating_cart_bar.dart';

Widget _wrap(CartEntity cart, {VoidCallback? onTap}) => MaterialApp(
      home: Scaffold(body: FloatingCartBar(cart: cart, onTap: onTap ?? () {})),
    );

void main() {
  testWidgets('shows item count and subtotal for a non-empty cart', (tester) async {
    final cart = CartEntity(items: [
      CartItemEntity(productId: 'p1', name: 'Rice', imageUrl: '', unitPrice: Money(1800), unit: ProductUnit.box, qty: 2),
      CartItemEntity(productId: 'p2', name: 'Oil', imageUrl: '', unitPrice: Money(1950), unit: ProductUnit.litre, qty: 1),
    ]);
    await tester.pumpWidget(_wrap(cart));
    await tester.pumpAndSettle();

    expect(find.text('3 items'), findsOneWidget);
    expect(find.text(cart.subtotal.formatted), findsOneWidget);
    expect(find.text('View Cart'), findsOneWidget);
  });

  testWidgets('singular "1 item" for exactly one unit', (tester) async {
    final cart = CartEntity(items: [
      CartItemEntity(productId: 'p1', name: 'Rice', imageUrl: '', unitPrice: Money(1800), unit: ProductUnit.box, qty: 1),
    ]);
    await tester.pumpWidget(_wrap(cart));
    await tester.pumpAndSettle();

    expect(find.text('1 item'), findsOneWidget);
  });

  testWidgets('is invisible to hit-testing when the cart is empty', (tester) async {
    var tapped = false;
    await tester.pumpWidget(_wrap(CartEntity.empty, onTap: () => tapped = true));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingCartBar), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(tapped, isFalse);
  });

  testWidgets('tapping the bar calls onTap when the cart has items', (tester) async {
    var tapped = false;
    final cart = CartEntity(items: [
      CartItemEntity(productId: 'p1', name: 'Rice', imageUrl: '', unitPrice: Money(1800), unit: ProductUnit.box, qty: 1),
    ]);
    await tester.pumpWidget(_wrap(cart, onTap: () => tapped = true));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingCartBar));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
  });
}
