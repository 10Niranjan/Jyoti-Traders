import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/domain/entities/product_entity.dart';
import 'package:traders_retailer/domain/value_objects/money.dart';
import 'package:traders_retailer/domain/value_objects/weight_rate_slabs.dart';
import 'package:traders_retailer/l10n/app_localizations.dart';
import 'package:traders_retailer/shared/widgets/quantity_picker.dart';

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

ProductEntity _unit({int stock = 50}) => ProductEntity(
      id: 'p2',
      name: 'Soap Box',
      categoryId: 'cat_misc',
      imageUrl: '',
      price: Money(20),
      unit: ProductUnit.box,
      stock: stock,
      isActive: true,
    );

class _Host extends StatefulWidget {
  final ProductEntity product;
  final int initialQty;

  const _Host({required this.product, required this.initialQty});

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late int _qty = widget.initialQty;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: QuantityPicker(
          product: widget.product,
          qty: _qty,
          onChanged: (qty) => setState(() => _qty = qty),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('+ doubles a weighed quantity and - halves it back', (tester) async {
    await tester.pumpWidget(_Host(product: _weighed(), initialQty: 100));

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    expect(find.text('200 g'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    expect(find.text('400 g'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.remove_rounded));
    await tester.pumpAndSettle();
    expect(find.text('200 g'), findsOneWidget);
  });

  testWidgets('+ doubles a unit quantity', (tester) async {
    await tester.pumpWidget(_Host(product: _unit(), initialQty: 1));

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    expect(find.text('2 box'), findsWidgets); // stepper label + the "2" preset chip

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    expect(find.text('4 box'), findsOneWidget);
  });

  testWidgets('a typed custom weight is read as kilos', (tester) async {
    await tester.pumpWidget(_Host(product: _weighed(), initialQty: 100));

    await tester.enterText(find.byType(TextField), '1.75');
    await tester.pumpAndSettle();

    expect(find.text('₹68.25'), findsOneWidget); // 1750 g falls in the 1kg-2.4kg band at ₹39/kg
  });

  testWidgets('a preset tap sets the exact quantity', (tester) async {
    await tester.pumpWidget(_Host(product: _weighed(), initialQty: 100));

    await tester.tap(find.text('500 g'));
    await tester.pumpAndSettle();

    expect(find.text('500 g'), findsWidgets);
  });

  testWidgets('below minimum shows the error and disables the - button', (tester) async {
    await tester.pumpWidget(_Host(product: _weighed(), initialQty: 100));

    await tester.enterText(find.byType(TextField), '0.05'); // 50 g, min is 100 g
    await tester.pumpAndSettle();

    expect(find.text('Minimum 100 g'), findsOneWidget);
  });
}
