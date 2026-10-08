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
const int _kCatalogSeedVersion = 4;

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

  // Version 4 only added photos. On a device already seeded with version 3,
  // fill the images in place instead of reseeding — a reseed would wipe any
  // products the admin added or edited in the meantime.
  if (existing.isNotEmpty && seededVersion == _kCatalogSeedVersion - 1) {
    await _backfillImages(catalogBox);
    await catalogBox.put(HiveKeys.catalogSeedVersion, _kCatalogSeedVersion);
    return;
  }

  final categories = <CategoryModel>[
    CategoryModel(id: 'cat_ayurved', name: 'Ayurvedic Medicine', iconUrl: _kCategoryImages['cat_ayurved'] ?? '', displayOrder: 1, isActive: true),
    CategoryModel(id: 'cat_grocery', name: 'Other Grocery', iconUrl: _kCategoryImages['cat_grocery'] ?? '', displayOrder: 2, isActive: true),
    CategoryModel(id: 'cat_electricals', name: 'Electricals', iconUrl: _kCategoryImages['cat_electricals'] ?? '', displayOrder: 3, isActive: true),
    CategoryModel(id: 'cat_cosmetics', name: 'Cosmetics & Soaps', iconUrl: _kCategoryImages['cat_cosmetics'] ?? '', displayOrder: 4, isActive: true),
    CategoryModel(id: 'cat_shampoo', name: 'Shampoos', iconUrl: _kCategoryImages['cat_shampoo'] ?? '', displayOrder: 5, isActive: true),
    CategoryModel(id: 'cat_tea', name: 'Tea', iconUrl: _kCategoryImages['cat_tea'] ?? '', displayOrder: 6, isActive: true),
    CategoryModel(id: 'cat_rice', name: 'Rice', iconUrl: _kCategoryImages['cat_rice'] ?? '', displayOrder: 7, isActive: true),
    CategoryModel(id: 'cat_oils', name: 'Oil & Oil Seeds', iconUrl: _kCategoryImages['cat_oils'] ?? '', displayOrder: 8, isActive: true),
    CategoryModel(id: 'cat_pulses', name: 'Lentils & Whole Pulses', iconUrl: _kCategoryImages['cat_pulses'] ?? '', displayOrder: 9, isActive: true),
    CategoryModel(id: 'cat_paan', name: 'Paan Patti Sahitya', iconUrl: _kCategoryImages['cat_paan'] ?? '', displayOrder: 10, isActive: true),
    CategoryModel(id: 'cat_firecrackers', name: 'Firecrackers', iconUrl: _kCategoryImages['cat_firecrackers'] ?? '', displayOrder: 11, isActive: true),
    CategoryModel(id: 'cat_cereals', name: 'Cereal Grains & Foodstuff', iconUrl: _kCategoryImages['cat_cereals'] ?? '', displayOrder: 12, isActive: true),
    CategoryModel(id: 'cat_hardware', name: 'Suut & Hardware', iconUrl: _kCategoryImages['cat_hardware'] ?? '', displayOrder: 13, isActive: true),
    CategoryModel(id: 'cat_suhana', name: 'Suhana', iconUrl: _kCategoryImages['cat_suhana'] ?? '', displayOrder: 14, isActive: true),
    CategoryModel(id: 'cat_suavda', name: 'Suavda', iconUrl: _kCategoryImages['cat_suavda'] ?? '', displayOrder: 15, isActive: true),
  ];

  // The old demo catalog's 16 products, re-homed into the new taxonomy so
  // nothing points at a category that no longer exists. Categories with no
  // natural match among these (Ayurvedic Medicine, Electricals, Shampoos,
  // Paan Patti Sahitya, Firecrackers, Suut & Hardware, Suhana, Suavda) are
  // seeded empty — real stock for those goes in via Admin > Manage Products.
  final products = <ProductModel>[
    _product('prod_1', 'Basmati Rice Premium 25kg', 'cat_rice', 2250, 'box', 40, isTopProduct: true),
    _product('prod_2', 'Wheat Atta 10kg', 'cat_cereals', 480, 'box', 60, isTopProduct: true),
    _product('prod_3', 'Fortune Soya Health Oil 15L Tin', 'cat_oils', 1680, 'piece', 25, isTopProduct: true),
    _product('prod_4', 'Pure Ghee 1L', 'cat_oils', 620, 'piece', 30, isTopProduct: true),
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

ProductModel _product(
  String id,
  String name,
  String categoryId,
  double price,
  String unit,
  int stock, {
  bool isTopProduct = false,
}) {
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
    imageUrl: _kProductImages[id] ?? '',
    price: price,
    unit: unit,
    stock: stock,
    isActive: true,
    rateSlabs: slabs,
    isTopProduct: isTopProduct,
  );
}

/// Demo photos from Wikimedia Commons (various free licences) — for demos
/// only; each product/category is replaced with the client's own photo once
/// they supply it. Loaded by URL like any uploaded image, so a dead link just
/// falls back to the placeholder icon. Categories without an entry
/// (Suavda) keep the placeholder.
const Map<String, String> _kProductImages = {
  'prod_1': 'https://thumb.wikimedia.org/wikipedia/commons/thumb/f/f8/Basmati_Rice_India%2C_raw.jpg/500px-Basmati_Rice_India%2C_raw.jpg',
  'prod_2': 'https://thumb.wikimedia.org/wikipedia/commons/thumb/2/26/Atta_flour.jpg/500px-Atta_flour.jpg',
  'prod_3': 'https://thumb.wikimedia.org/wikipedia/commons/thumb/f/ff/Soybean_Oil_%2810059657806%29.jpg/500px-Soybean_Oil_%2810059657806%29.jpg',
  'prod_4': 'https://thumb.wikimedia.org/wikipedia/commons/thumb/6/65/Pure_Ghee-Homemade-Maharashtra.jpg/500px-Pure_Ghee-Homemade-Maharashtra.jpg',
  'prod_5': 'https://thumb.wikimedia.org/wikipedia/commons/thumb/9/90/Kunyit_Bubuk.jpg/500px-Kunyit_Bubuk.jpg',
  'prod_6': 'https://thumb.wikimedia.org/wikipedia/commons/thumb/d/d4/Red_Chili_Powder_%28Lall_Mirch%29_%2849695826571%29.jpg/500px-Red_Chili_Powder_%28Lall_Mirch%29_%2849695826571%29.jpg',
  'prod_7': 'https://thumb.wikimedia.org/wikipedia/commons/thumb/a/a2/Tur_Dal.JPG/500px-Tur_Dal.JPG',
  'prod_8': 'https://thumb.wikimedia.org/wikipedia/commons/thumb/9/98/Split_Chickpeas.jpg/500px-Split_Chickpeas.jpg',
  'prod_9': 'https://thumb.wikimedia.org/wikipedia/commons/thumb/9/9e/Assorted_biscuits_Khong_Guan.JPG/500px-Assorted_biscuits_Khong_Guan.JPG',
  'prod_10': 'https://thumb.wikimedia.org/wikipedia/commons/thumb/2/28/Namkeen_05.jpg/500px-Namkeen_05.jpg',
  'prod_11': 'https://thumb.wikimedia.org/wikipedia/commons/thumb/f/f4/P%26G_TIDE_PRODUCTS_IN_CHINA.jpg/500px-P%26G_TIDE_PRODUCTS_IN_CHINA.jpg',
  'prod_12': 'https://thumb.wikimedia.org/wikipedia/commons/thumb/5/53/A_bar_of_soap.jpg/500px-A_bar_of_soap.jpg',
  'prod_13': 'https://thumb.wikimedia.org/wikipedia/commons/thumb/7/7f/Assam-mangalam.jpg/500px-Assam-mangalam.jpg',
  'prod_14': 'https://thumb.wikimedia.org/wikipedia/commons/thumb/2/26/Instant_coffee.jpg/500px-Instant_coffee.jpg',
  'prod_15': 'https://thumb.wikimedia.org/wikipedia/commons/thumb/d/d8/EdibleSalt.jpg/500px-EdibleSalt.jpg',
  'prod_16': 'https://thumb.wikimedia.org/wikipedia/commons/thumb/5/5b/Granulated_White_Sugar_with_Large_Crystals%2C_Bright_Front_Light.jpg/500px-Granulated_White_Sugar_with_Large_Crystals%2C_Bright_Front_Light.jpg',
};

const Map<String, String> _kCategoryImages = {
  'cat_ayurved': 'https://thumb.wikimedia.org/wikipedia/commons/thumb/2/2b/Bhringraj.jpg/500px-Bhringraj.jpg',
  'cat_grocery': 'https://thumb.wikimedia.org/wikipedia/commons/thumb/0/0d/Grocery_store_shelf_in_Russia.jpg/500px-Grocery_store_shelf_in_Russia.jpg',
  'cat_electricals': 'https://thumb.wikimedia.org/wikipedia/commons/thumb/b/b5/USB_power_socket_and_light_switch_installation.jpg/500px-USB_power_socket_and_light_switch_installation.jpg',
  'cat_cosmetics': 'https://thumb.wikimedia.org/wikipedia/commons/thumb/0/08/Makeup_cosmetics.jpg/500px-Makeup_cosmetics.jpg',
  'cat_shampoo': 'https://thumb.wikimedia.org/wikipedia/commons/thumb/6/68/Dove_shampoo_bottle.jpg/500px-Dove_shampoo_bottle.jpg',
  'cat_tea': 'https://thumb.wikimedia.org/wikipedia/commons/thumb/8/8a/Cup_of_black_tea.JPG/500px-Cup_of_black_tea.JPG',
  'cat_rice': 'https://thumb.wikimedia.org/wikipedia/commons/thumb/a/aa/Ceramic_bowl_full_of_white_rice.jpg/500px-Ceramic_bowl_full_of_white_rice.jpg',
  'cat_oils': 'https://thumb.wikimedia.org/wikipedia/commons/thumb/1/13/Bottle_of_olive_oil.jpg/500px-Bottle_of_olive_oil.jpg',
  'cat_pulses': 'https://thumb.wikimedia.org/wikipedia/commons/thumb/d/da/3_types_of_lentil.jpg/500px-3_types_of_lentil.jpg',
  'cat_paan': 'https://thumb.wikimedia.org/wikipedia/commons/thumb/7/71/Paan_ke_patte_%28Betel_leaf%29_from_India.jpg/500px-Paan_ke_patte_%28Betel_leaf%29_from_India.jpg',
  'cat_firecrackers': 'https://thumb.wikimedia.org/wikipedia/commons/thumb/3/36/Diwali_firecrackers_5.JPG/500px-Diwali_firecrackers_5.JPG',
  'cat_cereals': 'https://thumb.wikimedia.org/wikipedia/commons/thumb/f/f0/Wheat_Grain.jpg/500px-Wheat_Grain.jpg',
  'cat_hardware': 'https://thumb.wikimedia.org/wikipedia/commons/thumb/9/90/Hand-tool_set_with_bits_and_accessories_arranged_on_a_white_surface..jpg/500px-Hand-tool_set_with_bits_and_accessories_arranged_on_a_white_surface..jpg',
  'cat_suhana': 'https://thumb.wikimedia.org/wikipedia/commons/thumb/a/a7/Garam_Masala.JPG/500px-Garam_Masala.JPG',
};

/// Fills [field] from [urls] on every seeded item that has none, leaving
/// anything the admin already set (or added) untouched.
Future<void> _patchImages(Box box, String key, Map<String, String> urls, String field) async {
  final items = (box.get(key, defaultValue: []) as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  for (final item in items) {
    final url = urls[item['id']];
    if (url != null && (item[field] as String? ?? '').isEmpty) item[field] = url;
  }
  await box.put(key, items);
}

Future<void> _backfillImages(Box box) async {
  await _patchImages(box, HiveKeys.simulatedProducts, _kProductImages, 'imageUrl');
  await _patchImages(box, HiveKeys.simulatedCategories, _kCategoryImages, 'iconUrl');
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
