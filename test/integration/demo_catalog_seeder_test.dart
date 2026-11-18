import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:traders_retailer/core/constants/hive_keys.dart';
import 'package:traders_retailer/data/datasources/seed/demo_catalog_seeder.dart';

List<Map<String, dynamic>> _list(Box box, String key) => (box.get(key) as List)
    .map((e) => Map<String, dynamic>.from(e as Map))
    .toList();

/// The 15 per-category filler products version 5 added on top of the
/// original 16 (ids prod_17–prod_31).
final _kNewProductIds = List.generate(15, (i) => 'prod_${i + 17}').toSet();

void main() {
  late Directory tempDir;
  late Box box;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('jyoti_traders_seed_test_');
    Hive.init(tempDir.path);
    box = await Hive.openBox('catalog_cache');
  });

  tearDown(() async {
    await box.close();
    try {
      await Hive.deleteFromDisk();
      tempDir.deleteSync(recursive: true);
    } catch (_) {
      // Windows can hold the handle a moment longer; the OS temp dir is fine.
    }
  });

  test(
    'a fresh seed gives every demo product a photo, and all but Suavda a category photo',
    () async {
      await seedDemoCatalogIfEmpty(box);

      final products = _list(box, HiveKeys.simulatedProducts);
      expect(products, hasLength(31));
      final withoutPhoto = products
          .where((p) => (p['imageUrl'] as String).isEmpty)
          .map((p) => p['id']);
      expect(withoutPhoto, ['prod_31']); // Suavda product, same exception as its category icon

      final categories = _list(box, HiveKeys.simulatedCategories);
      final withoutIcon = categories
          .where((c) => (c['iconUrl'] as String).isEmpty)
          .map((c) => c['id']);
      expect(withoutIcon, ['cat_suavda']);
    },
  );

  test(
    'a phone already on version 3 gets photos and the new per-category products, without losing what the admin changed',
    () async {
      await seedDemoCatalogIfEmpty(box);

      // Rewind to how version 3 left the store: no photos, the 8
      // then-empty categories still without a single product, plus an
      // admin edit and an admin-created product.
      final products = _list(box, HiveKeys.simulatedProducts)
          .where((p) => !_kNewProductIds.contains(p['id']))
          .toList();
      for (final p in products) {
        p['imageUrl'] = '';
      }
      products.first['stock'] = 7;
      products.add({
        ...products.first,
        'id': 'admin_added',
        'name': 'Added by admin',
        'imageUrl': '',
      });
      await box.put(HiveKeys.simulatedProducts, products);
      await box.put(HiveKeys.catalogSeedVersion, 3);

      await seedDemoCatalogIfEmpty(box);

      final after = _list(box, HiveKeys.simulatedProducts);
      expect(after, hasLength(16 + _kNewProductIds.length + 1)); // nothing dropped, new ones appended
      expect(after.firstWhere((p) => p['id'] == 'prod_1')['stock'], 7); // admin edit kept
      expect(
        (after.firstWhere((p) => p['id'] == 'prod_1')['imageUrl'] as String).startsWith('https://'),
        isTrue,
      );
      expect(
        after.singleWhere((p) => p['id'] == 'admin_added')['imageUrl'],
        '',
      ); // not seeded, left alone
      expect(
        after.where((p) => _kNewProductIds.contains(p['id'])),
        hasLength(_kNewProductIds.length),
      ); // every v5 category-filler product caught up
      expect(box.get(HiveKeys.catalogSeedVersion), 5);
    },
  );

  test('a photo the admin already set is never overwritten', () async {
    await seedDemoCatalogIfEmpty(box);
    final products = _list(box, HiveKeys.simulatedProducts);
    products.first['imageUrl'] = 'https://example.com/mine.jpg';
    await box.put(HiveKeys.simulatedProducts, products);
    await box.put(HiveKeys.catalogSeedVersion, 3);

    await seedDemoCatalogIfEmpty(box);

    expect(
      _list(box, HiveKeys.simulatedProducts).first['imageUrl'],
      'https://example.com/mine.jpg',
    );
  });
}
