import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/hive_keys.dart';
import '../../../core/network/firebase_mode.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';

/// Phase 4's Admin product/category management UI doesn't exist yet, so
/// without this the simulated catalog would stay empty forever and nothing
/// in Phase 3 would be browsable. Seeds the 8 categories from PRD §5 plus a
/// couple of demo products each, once, only in Firestore-simulation mode.
Future<void> seedDemoCatalogIfEmpty(Box catalogBox) async {
  final useMock = _isSimulationMode();
  if (!useMock) return;

  final List<dynamic> existing = catalogBox.get(HiveKeys.simulatedCategories, defaultValue: []);
  if (existing.isNotEmpty) return;

  final categories = <CategoryModel>[
    CategoryModel(id: 'cat_grains', name: 'Atta, Rice & Grains', iconUrl: '', displayOrder: 1, isActive: true),
    CategoryModel(id: 'cat_oils', name: 'Oils & Ghee', iconUrl: '', displayOrder: 2, isActive: true),
    CategoryModel(id: 'cat_spices', name: 'Spices & Masalas', iconUrl: '', displayOrder: 3, isActive: true),
    CategoryModel(id: 'cat_pulses', name: 'Pulses & Lentils', iconUrl: '', displayOrder: 4, isActive: true),
    CategoryModel(id: 'cat_snacks', name: 'Snacks & Biscuits', iconUrl: '', displayOrder: 5, isActive: true),
    CategoryModel(id: 'cat_cleaning', name: 'Soaps & Cleaning Products', iconUrl: '', displayOrder: 6, isActive: true),
    CategoryModel(id: 'cat_beverages', name: 'Beverages & Drinks', iconUrl: '', displayOrder: 7, isActive: true),
    CategoryModel(id: 'cat_staples', name: 'Daily Staples', iconUrl: '', displayOrder: 8, isActive: true),
  ];

  final products = <ProductModel>[
    _product('prod_1', 'Basmati Rice Premium 25kg', 'cat_grains', 2250, 'box', 40),
    _product('prod_2', 'Wheat Atta 10kg', 'cat_grains', 480, 'box', 60),
    _product('prod_3', 'Fortune Soya Health Oil 15L Tin', 'cat_oils', 1680, 'piece', 25),
    _product('prod_4', 'Pure Ghee 1L', 'cat_oils', 620, 'piece', 30),
    _product('prod_5', 'Turmeric Powder 1kg', 'cat_spices', 210, 'kg', 50),
    _product('prod_6', 'Red Chilli Powder 1kg', 'cat_spices', 260, 'kg', 45),
    _product('prod_7', 'Toor Dal 10kg', 'cat_pulses', 1150, 'box', 35),
    _product('prod_8', 'Chana Dal 10kg', 'cat_pulses', 980, 'box', 32),
    _product('prod_9', 'Assorted Biscuits Box (24 pack)', 'cat_snacks', 580, 'box', 40),
    _product('prod_10', 'Namkeen Mix 5kg', 'cat_snacks', 720, 'box', 20),
    _product('prod_11', 'Detergent Powder 5kg', 'cat_cleaning', 540, 'box', 28),
    _product('prod_12', 'Bathing Soap (72 pack)', 'cat_cleaning', 860, 'box', 22),
    _product('prod_13', 'Tea Powder 1kg', 'cat_beverages', 420, 'kg', 38),
    _product('prod_14', 'Instant Coffee 200g', 'cat_beverages', 340, 'piece', 26),
    _product('prod_15', 'Tata Salt Iodized (24 x 1kg Box)', 'cat_staples', 580, 'box', 42),
    _product('prod_16', 'Sugar 25kg', 'cat_staples', 1320, 'box', 30),
  ];

  await catalogBox.put(HiveKeys.simulatedCategories, categories.map((c) => c.toJson()).toList());
  await catalogBox.put(HiveKeys.simulatedProducts, products.map((p) => p.toJson()).toList());

  debugPrint('DemoCatalogSeeder: seeded ${categories.length} categories and ${products.length} products.');
}

ProductModel _product(String id, String name, String categoryId, double price, String unit, int stock) {
  return ProductModel(
    id: id,
    name: name,
    categoryId: categoryId,
    imageUrl: '',
    price: price,
    unit: unit,
    stock: stock,
    isActive: true,
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
