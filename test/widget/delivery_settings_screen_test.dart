import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/data/repositories/repository_providers.dart';
import 'package:traders_retailer/domain/entities/delivery_config_entity.dart';
import 'package:traders_retailer/domain/repositories/delivery_config_repository.dart';
import 'package:traders_retailer/features/admin/screens/delivery_settings_screen.dart';
import 'package:traders_retailer/l10n/app_localizations.dart';

import '../helpers/test_viewport.dart';

class FakeDeliveryConfigRepository implements DeliveryConfigRepository {
  DeliveryConfigEntity config;
  final List<DeliveryConfigEntity> updated = [];

  FakeDeliveryConfigRepository(this.config);

  @override
  Stream<DeliveryConfigEntity> watchConfig() => Stream.value(config);

  @override
  Future<void> updateConfig(DeliveryConfigEntity newConfig) async {
    config = newConfig;
    updated.add(newConfig);
  }
}

Widget _wrap(FakeDeliveryConfigRepository repo) => ProviderScope(
  overrides: [deliveryConfigRepositoryProvider.overrideWithValue(repo)],
  child: const MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: DeliverySettingsScreen(),
  ),
);

void main() {
  useTallTestViewport();

  testWidgets('pre-fills the form from the current config', (tester) async {
    await tester.pumpWidget(
      _wrap(
        FakeDeliveryConfigRepository(
          const DeliveryConfigEntity(
            warehouseLat: 19.076,
            warehouseLng: 72.8777,
            perKmRate: 12.0,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextFormField, '19.076'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '72.8777'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '12.0'), findsOneWidget);
  });

  testWidgets('rejects an invalid rate', (tester) async {
    final repo = FakeDeliveryConfigRepository(
      const DeliveryConfigEntity(
        warehouseLat: 19.076,
        warehouseLng: 72.8777,
        perKmRate: 12.0,
      ),
    );
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Rate (₹ per km)'),
      '0',
    );
    // Save only enables once something changed; let that frame land first.
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Save Changes'));
    await tester.pumpAndSettle();

    expect(find.text('Rate must be above ₹0'), findsOneWidget);
    expect(repo.updated, isEmpty);
  });

  testWidgets('saves valid changes and shows a confirmation', (tester) async {
    final repo = FakeDeliveryConfigRepository(
      const DeliveryConfigEntity(
        warehouseLat: 19.076,
        warehouseLng: 72.8777,
        perKmRate: 12.0,
      ),
    );
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Rate (₹ per km)'),
      '15',
    );
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Save Changes'));
    await tester.pumpAndSettle();

    expect(repo.updated, hasLength(1));
    expect(repo.updated.single.perKmRate, 15);
    expect(
      repo.updated.single.warehouseLat,
      19.076,
    ); // unchanged fields preserved
    expect(find.text('✓ Delivery settings saved successfully'), findsOneWidget);
  });

  group('redesigned form', () {
    FakeDeliveryConfigRepository repoAt(double rate) =>
        FakeDeliveryConfigRepository(
          DeliveryConfigEntity(
            warehouseLat: 19.076,
            warehouseLng: 72.8777,
            perKmRate: rate,
          ),
        );

    ElevatedButton saveButton(WidgetTester tester) =>
        tester.widget(find.widgetWithText(ElevatedButton, 'Save Changes'));

    final rateField = find.widgetWithText(TextFormField, 'Rate (₹ per km)');

    testWidgets('Save stays disabled until something changes', (tester) async {
      await tester.pumpWidget(_wrap(repoAt(12)));
      await tester.pumpAndSettle();

      expect(saveButton(tester).onPressed, isNull);
      expect(find.text('All changes saved'), findsOneWidget);

      await tester.enterText(rateField, '15');
      await tester.pump();

      expect(saveButton(tester).onPressed, isNotNull);
      expect(find.text('Unsaved changes'), findsOneWidget);
    });

    testWidgets('editing back to the saved value is clean again', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(repoAt(12)));
      await tester.pumpAndSettle();

      await tester.enterText(rateField, '15');
      await tester.pump();
      await tester.enterText(rateField, '12.0');
      await tester.pump();

      expect(saveButton(tester).onPressed, isNull);
    });

    testWidgets('a successful save leaves the form clean', (tester) async {
      await tester.pumpWidget(_wrap(repoAt(12)));
      await tester.pumpAndSettle();

      await tester.enterText(rateField, '15');
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save Changes'));
      await tester.pumpAndSettle();

      expect(saveButton(tester).onPressed, isNull);
      expect(find.text('All changes saved'), findsOneWidget);
    });

    testWidgets('the preview shows what retailers pay at the current rate', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(repoAt(12)));
      await tester.pumpAndSettle();

      // 2, 5, 10 and 25 km at ₹12/km.
      expect(find.text('₹24'), findsOneWidget);
      expect(find.text('₹60'), findsOneWidget);
      expect(find.text('₹120'), findsOneWidget);
      expect(find.text('₹300'), findsOneWidget);
    });

    testWidgets('a quick-rate chip fills the field and the preview follows', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(repoAt(12)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('₹8'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextFormField, '8'), findsOneWidget);
      expect(find.text('₹80'), findsOneWidget); // 10 km at ₹8
      expect(find.text('₹120'), findsNothing);
    });

    testWidgets('the stepper nudges the rate by one', (tester) async {
      await tester.pumpWidget(_wrap(repoAt(12)));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Increase rate'));
      await tester.pumpAndSettle();
      expect(find.text('₹130'), findsOneWidget); // 10 km at ₹13

      await tester.tap(find.byTooltip('Decrease rate'));
      await tester.tap(find.byTooltip('Decrease rate'));
      await tester.pumpAndSettle();
      expect(find.text('₹110'), findsOneWidget); // 10 km at ₹11
    });

    testWidgets('the stepper cannot take the rate below ₹1', (tester) async {
      await tester.pumpWidget(_wrap(repoAt(1)));
      await tester.pumpAndSettle();

      final decrease = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.remove_rounded),
          matching: find.byType(IconButton),
        ),
      );
      expect(decrease.onPressed, isNull);
    });

    testWidgets('a rate that is not a number shows a dash, not a crash', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(repoAt(12)));
      await tester.pumpAndSettle();

      await tester.enterText(rateField, 'abc');
      await tester.pumpAndSettle();

      expect(find.text('—'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });
}
