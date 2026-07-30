import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/hive_keys.dart';
import '../../../core/network/firebase_mode.dart';
import '../../../domain/value_objects/weight_rate_slabs.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';

/// Bump whenever the taxonomy below changes materially — forces a one-time
/// reseed on devices that already ran an older seed (a fresh install always
/// gets the current list regardless). Only touches simulation-mode Hive
/// data, so it's safe to overwrite: a real Firestore catalog is never
/// affected once a real Firebase project is configured (see
/// `_isSimulationMode`).
const int _kCatalogSeedVersion = 2;

/// Phase 4's Admin product/category management UI doesn't exist yet, so
/// without this the simulated catalog would stay empty forever and nothing
/// in Phase 3 would be browsable. Seeds the client's real stock groups
/// (PRD §5) plus a couple of demo products each, once per [_kCatalogSeedVersion],
/// only in Firestore-simulation mode.
Future<void> seedDemoCatalogIfEmpty(Box catalogBox) async {
  final useMock = _isSimulationMode();
  if (!useMock) return;

  final List<dynamic> existing = catalogBox.get(HiveKeys.simulatedCategories, defaultValue: []);
  final seededVersion = catalogBox.get(HiveKeys.catalogSeedVersion, defaultValue: 0) as int;
  if (existing.isNotEmpty && seededVersion >= _kCatalogSeedVersion) return;

  final categories = <CategoryModel>[
    CategoryModel(id: 'cat_ayurved', name: 'Ayurvedic Medicine', iconUrl: '', displayOrder: 1, isActive: true),
    CategoryModel(id: 'cat_grocery', name: 'Other Grocery', iconUrl: '', displayOrder: 2, isActive: true),
    CategoryModel(id: 'cat_electricals', name: 'Electricals', iconUrl: '', displayOrder: 3, isActive: true),
    CategoryModel(id: 'cat_cosmetics', name: 'Cosmetics & Soaps', iconUrl: '', displayOrder: 4, isActive: true),
    CategoryModel(id: 'cat_shampoo', name: 'Shampoos', iconUrl: '', displayOrder: 5, isActive: true),
    CategoryModel(id: 'cat_tea', name: 'Tea', iconUrl: '', displayOrder: 6, isActive: true),
    CategoryModel(id: 'cat_rice', name: 'Rice', iconUrl: '', displayOrder: 7, isActive: true),
    CategoryModel(id: 'cat_oils', name: 'Oil & Oil Seeds', iconUrl: '', displayOrder: 8, isActive: true),
    CategoryModel(id: 'cat_pulses', name: 'Lentils & Whole Pulses', iconUrl: '', displayOrder: 9, isActive: true),
    CategoryModel(id: 'cat_paan', name: 'Paan Patti Sahitya', iconUrl: '', displayOrder: 10, isActive: true),
    CategoryModel(id: 'cat_firecrackers', name: 'Firecrackers', iconUrl: '', displayOrder: 11, isActive: true),
    CategoryModel(id: 'cat_cereals', name: 'Cereal Grains & Foodstuff', iconUrl: '', displayOrder: 12, isActive: true),
    CategoryModel(id: 'cat_hardware', name: 'Suut & Hardware', iconUrl: '', displayOrder: 13, isActive: true),
    CategoryModel(id: 'cat_suhana', name: 'Suhana', iconUrl: '', displayOrder: 14, isActive: true),
    CategoryModel(id: 'cat_suavda', name: 'Suavda', iconUrl: '', displayOrder: 15, isActive: true),
  ];

  // The old demo catalog's 16 products, re-homed into the new taxonomy so
  // nothing points at a category that no longer exists. Categories with no
  // natural match among these (Ayurvedic Medicine, Electricals, Shampoos,
  // Paan Patti Sahitya, Firecrackers, Suut & Hardware, Suhana, Suavda) are
  // seeded empty — real stock for those goes in via Admin > Manage Products.
  final products = <ProductModel>[
    _product('prod_1', 'Basmati Rice Premium 25kg', 'cat_rice', 2250, 'box', 40),
    _product('prod_2', 'Wheat Atta 10kg', 'cat_cereals', 480, 'box', 60),
    _product('prod_3', 'Fortune Soya Health Oil 15L Tin', 'cat_oils', 1680, 'piece', 25),
    _product('prod_4', 'Pure Ghee 1L', 'cat_oils', 620, 'piece', 30),
    _product('prod_5', 'Turmeric Powder 1kg', 'cat_grocery', 210, 'kg', 50),
    _product('prod_6', 'Red Chilli Powder 1kg', 'cat_grocery', 260, 'kg', 45),
    _product('prod_7', 'Toor Dal 10kg', 'cat_pulses', 1150, 'box', 35),
    _product('prod_8', 'Chana Dal 10kg', 'cat_pulses', 980, 'box', 32),
    _product('prod_9', 'Assorted Biscuits Box (24 pack)', 'cat_grocery', 580, 'box', 40),
    _product('prod_10', 'Namkeen Mix 5kg', 'cat_grocery', 720, 'box', 20),
    _product('prod_11', 'Detergent Powder 5kg', 'cat_grocery', 540, 'box', 28),
    _product('prod_12', 'Bathing Soap (72 pack)', 'cat_cosmetics', 860, 'box', 22),
    _product('prod_13', 'Tea Powder 1kg', 'cat_tea', 420, 'kg', 38),
    _product('prod_14', 'Instant Coffee 200g', 'cat_grocery', 340, 'piece', 26),
    _product('prod_15', 'Tata Salt Iodized (24 x 1kg Box)', 'cat_grocery', 580, 'box', 42),
    _product('prod_16', 'Sugar 25kg', 'cat_grocery', 1320, 'box', 30),
  ];

  await catalogBox.put(HiveKeys.simulatedCategories, categories.map((c) => c.toJson()).toList());
  await catalogBox.put(HiveKeys.simulatedProducts, products.map((p) => p.toJson()).toList());
  await catalogBox.put(HiveKeys.catalogSeedVersion, _kCatalogSeedVersion);

  debugPrint('DemoCatalogSeeder: seeded ${categories.length} categories and ${products.length} products.');
}

ProductModel _product(String id, String name, String categoryId, double price, String unit, int stock) {
  // kg products demo the slab ladder; their rates are scaled off the flat
  // price so each seeded item still looks like its own commodity.
  final slabs = unit == 'kg'
      ? WeightRateSlabs(
          below240g: price * 1.10,
          upto999g: price,
          upto2400g: price * 0.975,
          above2400g: price * 0.95,
        )
      : null;
  return ProductModel(
    id: id,
    name: name,
    categoryId: categoryId,
    imageUrl: '',
    price: price,
    unit: unit,
    stock: stock,
    isActive: true,
    rateSlabs: slabs,
  );
}

bool _isSimulationMode() {
  try {
    return isFirebasePlaceholder(fb.FirebaseAuth.instance.app);
  } catch (e) {
    // Firebase.initializeApp() failed entirely (e.g. no platform config) —
    // that's simulation mode too.
    return true;
  }
}
