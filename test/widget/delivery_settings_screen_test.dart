import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/data/repositories/repository_providers.dart';
import 'package:traders_retailer/domain/entities/delivery_config_entity.dart';
import 'package:traders_retailer/domain/repositories/delivery_config_repository.dart';
import 'package:traders_retailer/features/admin/screens/delivery_settings_screen.dart';

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
      child: const MaterialApp(home: DeliverySettingsScreen()),
    );

void main() {
  useTallTestViewport();

  testWidgets('pre-fills the form from the current config', (tester) async {
    await tester.pumpWidget(_wrap(FakeDeliveryConfigRepository(
      const DeliveryConfigEntity(warehouseLat: 19.076, warehouseLng: 72.8777, perKmRate: 12.0),
    )));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextFormField, '19.076'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '72.8777'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '12.0'), findsOneWidget);
  });

  testWidgets('rejects an invalid rate', (tester) async {
    final repo = FakeDeliveryConfigRepository(
      const DeliveryConfigEntity(warehouseLat: 19.076, warehouseLng: 72.8777, perKmRate: 12.0),
    );
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Rate (₹ per km)'), '0');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Save Changes'));
    await tester.pumpAndSettle();

    expect(find.text('Rate must be above ₹0'), findsOneWidget);
    expect(repo.updated, isEmpty);
  });

  testWidgets('saves valid changes and shows a confirmation', (tester) async {
    final repo = FakeDeliveryConfigRepository(
      const DeliveryConfigEntity(warehouseLat: 19.076, warehouseLng: 72.8777, perKmRate: 12.0),
    );
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Rate (₹ per km)'), '15');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Save Changes'));
    await tester.pumpAndSettle();

    expect(repo.updated, hasLength(1));
    expect(repo.updated.single.perKmRate, 15);
    expect(repo.updated.single.warehouseLat, 19.076); // unchanged fields preserved
    expect(find.text('Delivery settings updated.'), findsOneWidget);
  });
}
