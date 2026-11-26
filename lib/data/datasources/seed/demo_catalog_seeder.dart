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
const int _kCatalogSeedVersion = 6;

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

  // A device already seeded with an older version: top it up rather than
  // reseeding — a reseed would wipe any products the admin added or edited
  // in the meantime. Fills in any still-missing photos (the v3→v4 step) and
  // appends any new demo products (by id) it doesn't already have (the
  // v4→v5 step) — both are no-ops on anything the admin already touched.
  if (existing.isNotEmpty && seededVersion < _kCatalogSeedVersion) {
    await _backfillImages(catalogBox);
    await _appendNewProducts(catalogBox);
    await catalogBox.put(HiveKeys.catalogSeedVersion, _kCatalogSeedVersion);
    return;
  }

  final categories = _demoCategories();
  final products = _demoProducts();

  await catalogBox.put(HiveKeys.simulatedCategories, categories.map((c) => c.toJson()).toList());
  await catalogBox.put(HiveKeys.simulatedProducts, products.map((p) => p.toJson()).toList());
  await catalogBox.put(HiveKeys.catalogSeedVersion, _kCatalogSeedVersion);

  debugPrint('DemoCatalogSeeder: seeded ${categories.length} categories and ${products.length} products.');
}

/// Version 5's additions: one or two demo products for each category that
/// shipped empty in version 4, so every category is actually browsable.
/// Suavda keeps no product-level photo either, matching its category icon.
List<ProductModel> get _kNewProducts => [
  _product('prod_17', 'Chyawanprash 1kg', 'cat_ayurved', 320, 'piece', 25),
  _product('prod_18', 'Ashwagandha Churna 200g', 'cat_ayurved', 180, 'piece', 30),
  _product('prod_19', 'LED Bulb 9W (Pack of 2)', 'cat_electricals', 150, 'piece', 60),
  _product('prod_20', 'Extension Board 4-Socket', 'cat_electricals', 320, 'piece', 20),
  _product('prod_21', 'Anti-Dandruff Shampoo 340ml', 'cat_shampoo', 210, 'piece', 40),
  _product('prod_22', 'Herbal Shampoo 650ml', 'cat_shampoo', 280, 'piece', 35),
  _product('prod_23', 'Kattha (Catechu) 500g', 'cat_paan', 140, 'piece', 30),
  _product('prod_24', 'Supari (Betel Nut)', 'cat_paan', 480, 'kg', 25),
  _product('prod_25', 'Sparklers Box (10 pcs)', 'cat_firecrackers', 150, 'box', 50),
  _product('prod_26', 'Flower Pots (Anar) Pack of 5', 'cat_firecrackers', 350, 'box', 20),
  _product('prod_27', 'Nylon Rope 50m', 'cat_hardware', 220, 'piece', 30),
  _product('prod_28', 'Cotton Thread Spool (Suut) Pack of 10', 'cat_hardware', 180, 'box', 40),
  _product('prod_29', 'Suhana Garam Masala 500g', 'cat_suhana', 160, 'piece', 45),
  _product('prod_30', 'Suhana Chicken Masala 200g', 'cat_suhana', 95, 'piece', 50),
  _product('prod_31', 'Suavda Special Mix 500g', 'cat_suavda', 150, 'piece', 20),
];

/// Version 6: a fuller shelf (3 more per category) so every screen of a demo
/// build looks like a real shop. Photos fall back to the category's icon.
List<ProductModel> get _kMoreProducts => [
  _product('prod_32', 'Triphala Churna 500g', 'cat_ayurved', 160, 'piece', 40),
  _product('prod_33', 'Amla Juice 1L', 'cat_ayurved', 190, 'piece', 35),
  _product('prod_34', 'Pudin Hara (Pack of 10)', 'cat_ayurved', 220, 'box', 30),
  _product('prod_35', 'Poha (Flattened Rice)', 'cat_grocery', 60, 'kg', 120, isTopProduct: true),
  _product('prod_36', 'Jaggery (Gul)', 'cat_grocery', 58, 'kg', 90),
  _product('prod_37', 'Maggi Noodles (96 pack)', 'cat_grocery', 1150, 'box', 25, isTopProduct: true),
  _product('prod_38', 'Matchbox Bundle (10 x 10)', 'cat_grocery', 95, 'box', 3),
  _product('prod_39', 'AA Battery (Pack of 10)', 'cat_electricals', 180, 'box', 45),
  _product('prod_40', 'Copper Wire 90m Coil', 'cat_electricals', 1450, 'piece', 12),
  _product('prod_41', 'Rechargeable Torch', 'cat_electricals', 260, 'piece', 30),
  _product('prod_42', 'Lux Soap (Pack of 4)', 'cat_cosmetics', 150, 'box', 60),
  _product('prod_43', 'Coconut Hair Oil 500ml', 'cat_cosmetics', 210, 'piece', 50),
  _product('prod_44', 'Fairness Cream 50g (Box of 12)', 'cat_cosmetics', 780, 'box', 18),
  _product('prod_45', 'Shampoo Sachets (Strip of 16)', 'cat_shampoo', 32, 'piece', 200, isTopProduct: true),
  _product('prod_46', 'Conditioner 180ml', 'cat_shampoo', 165, 'piece', 40),
  _product('prod_47', 'Baby Shampoo 200ml', 'cat_shampoo', 195, 'piece', 25),
  _product('prod_48', 'Assam CTC Tea', 'cat_tea', 380, 'kg', 70, isTopProduct: true),
  _product('prod_49', 'Green Tea (100 bags)', 'cat_tea', 450, 'box', 20),
  _product('prod_50', 'Masala Chai Premix 1kg', 'cat_tea', 340, 'piece', 30),
  _product('prod_51', 'Kolam Rice', 'cat_rice', 62, 'kg', 300, isTopProduct: true),
  _product('prod_52', 'Indrayani Rice', 'cat_rice', 78, 'kg', 250),
  _product('prod_53', 'Sona Masoori Rice 25kg', 'cat_rice', 1450, 'box', 30),
  _product('prod_54', 'Groundnut Oil 15L Tin', 'cat_oils', 2650, 'piece', 15),
  _product('prod_55', 'Mustard Oil 1L (Box of 12)', 'cat_oils', 1980, 'box', 20),
  _product('prod_56', 'Sesame Seeds (Til)', 'cat_oils', 180, 'kg', 40),
  _product('prod_57', 'Moong Dal', 'cat_pulses', 118, 'kg', 150),
  _product('prod_58', 'Masoor Dal', 'cat_pulses', 96, 'kg', 140),
  _product('prod_59', 'Kabuli Chana', 'cat_pulses', 132, 'kg', 2),
  _product('prod_60', 'Rajma (Red Kidney Beans)', 'cat_pulses', 145, 'kg', 80),
  _product('prod_61', 'Gulkand 1kg', 'cat_paan', 240, 'piece', 25),
  _product('prod_62', 'Saunf (Fennel Seeds)', 'cat_paan', 210, 'kg', 35),
  _product('prod_63', 'Elaichi (Green Cardamom)', 'cat_paan', 2400, 'kg', 8),
  _product('prod_64', 'Ground Chakra (Box of 10)', 'cat_firecrackers', 280, 'box', 40),
  _product('prod_65', 'Rocket (Box of 10)', 'cat_firecrackers', 420, 'box', 25),
  _product('prod_66', 'Diya Set (Pack of 12)', 'cat_firecrackers', 120, 'box', 60),
  _product('prod_67', 'Jowar', 'cat_cereals', 48, 'kg', 200),
  _product('prod_68', 'Bajra', 'cat_cereals', 38, 'kg', 180),
  _product('prod_69', 'Rava (Sooji)', 'cat_cereals', 52, 'kg', 160),
  _product('prod_70', 'Besan (Gram Flour)', 'cat_cereals', 95, 'kg', 110),
  _product('prod_71', 'Plastic Bucket 20L', 'cat_hardware', 180, 'piece', 30),
  _product('prod_72', 'Padlock 50mm', 'cat_hardware', 210, 'piece', 25),
  _product('prod_73', 'Jute Sutli 1kg', 'cat_hardware', 140, 'piece', 40),
  _product('prod_74', 'Suhana Pav Bhaji Masala 100g', 'cat_suhana', 65, 'piece', 80),
  _product('prod_75', 'Suhana Kanda Lasun Masala 200g', 'cat_suhana', 110, 'piece', 70, isTopProduct: true),
  _product('prod_76', 'Suhana Misal Masala 100g', 'cat_suhana', 60, 'piece', 4),
  _product('prod_77', 'Suavda Mouth Freshener Jar', 'cat_suavda', 120, 'piece', 30),
  _product('prod_78', 'Suavda Mukhwas 1kg', 'cat_suavda', 260, 'piece', 25),
];

/// Appends any of [_kNewProducts] a device doesn't already have, by id —
/// never touches a product that's already there, admin-edited or not.
Future<void> _appendNewProducts(Box box) async {
  final items = (box.get(HiveKeys.simulatedProducts, defaultValue: []) as List)
      .map((e) => Map<String, dynamic>.from(e as Map))
      .toList();
  final existingIds = items.map((p) => p['id'] as String).toSet();
  final toAdd = _demoProducts().where((p) => !existingIds.contains(p.id));
  items.addAll(toAdd.map((p) => p.toJson()));
  await box.put(HiveKeys.simulatedProducts, items);
}

ProductModel _product(
  String id,
  String name,
  String categoryId,
  double price,
  String unit,
  double stock, {
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
    imageUrl: _kProductImages[id] ?? _kCategoryImages[categoryId] ?? '',
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
  // Version 5's new per-category products reuse that category's own icon
  // photo rather than sourcing a separate image per product — Suavda (no
  // category icon either) is the one deliberate exception, same as before.
  'prod_17': 'https://thumb.wikimedia.org/wikipedia/commons/thumb/2/2b/Bhringraj.jpg/500px-Bhringraj.jpg',
  'prod_18': 'https://thumb.wikimedia.org/wikipedia/commons/thumb/2/2b/Bhringraj.jpg/500px-Bhringraj.jpg',
  'prod_19': 'https://thumb.wikimedia.org/wikipedia/commons/thumb/b/b5/USB_power_socket_and_light_switch_installation.jpg/500px-USB_power_socket_and_light_switch_installation.jpg',
  'prod_20': 'https://thumb.wikimedia.org/wikipedia/commons/thumb/b/b5/USB_power_socket_and_light_switch_installation.jpg/500px-USB_power_socket_and_light_switch_installation.jpg',
  'prod_21': 'https://thumb.wikimedia.org/wikipedia/commons/thumb/6/68/Dove_shampoo_bottle.jpg/500px-Dove_shampoo_bottle.jpg',
  'prod_22': 'https://thumb.wikimedia.org/wikipedia/commons/thumb/6/68/Dove_shampoo_bottle.jpg/500px-Dove_shampoo_bottle.jpg',
  'prod_23': 'https://thumb.wikimedia.org/wikipedia/commons/thumb/7/71/Paan_ke_patte_%28Betel_leaf%29_from_India.jpg/500px-Paan_ke_patte_%28Betel_leaf%29_from_India.jpg',
  'prod_24': 'https://thumb.wikimedia.org/wikipedia/commons/thumb/7/71/Paan_ke_patte_%28Betel_leaf%29_from_India.jpg/500px-Paan_ke_patte_%28Betel_leaf%29_from_India.jpg',
  'prod_25': 'https://thumb.wikimedia.org/wikipedia/commons/thumb/3/36/Diwali_firecrackers_5.JPG/500px-Diwali_firecrackers_5.JPG',
  'prod_26': 'https://thumb.wikimedia.org/wikipedia/commons/thumb/3/36/Diwali_firecrackers_5.JPG/500px-Diwali_firecrackers_5.JPG',
  'prod_27': 'https://thumb.wikimedia.org/wikipedia/commons/thumb/9/90/Hand-tool_set_with_bits_and_accessories_arranged_on_a_white_surface..jpg/500px-Hand-tool_set_with_bits_and_accessories_arranged_on_a_white_surface..jpg',
  'prod_28': 'https://thumb.wikimedia.org/wikipedia/commons/thumb/9/90/Hand-tool_set_with_bits_and_accessories_arranged_on_a_white_surface..jpg/500px-Hand-tool_set_with_bits_and_accessories_arranged_on_a_white_surface..jpg',
  'prod_29': 'https://thumb.wikimedia.org/wikipedia/commons/thumb/a/a7/Garam_Masala.JPG/500px-Garam_Masala.JPG',
  'prod_30': 'https://thumb.wikimedia.org/wikipedia/commons/thumb/a/a7/Garam_Masala.JPG/500px-Garam_Masala.JPG',
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

List<CategoryModel> _demoCategories() => <CategoryModel>[
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

List<ProductModel> _demoProducts() => <ProductModel>[
    _product('prod_1', 'Basmati Rice Premium 25kg', 'cat_rice', 2250, 'box', 40, isTopProduct: true),
    _product('prod_2', 'Wheat Atta 10kg', 'cat_cereals', 480, 'box', 60, isTopProduct: true),
    _product('prod_3', 'Fortune Soya Health Oil 15L Tin', 'cat_oils', 1680, 'piece', 25, isTopProduct: true),
    _product('prod_4', 'Pure Ghee 1L', 'cat_oils', 620, 'piece', 30, isTopProduct: true),
    _product('prod_5', 'Turmeric Powder 1kg', 'cat_grocery', 210, 'kg', 50),
    _product('prod_6', 'Red Chilli Powder 1kg', 'cat_grocery', 260, 'kg', 45),
    // Deliberately low stock — demos the low-stock banner/alert; also the
    // product the seeded "Low Stock Alert" notification above refers to.
    _product('prod_7', 'Toor Dal 10kg', 'cat_pulses', 1150, 'box', 4),
    _product('prod_8', 'Chana Dal 10kg', 'cat_pulses', 980, 'box', 32),
    _product('prod_9', 'Assorted Biscuits Box (24 pack)', 'cat_grocery', 580, 'box', 40),
    _product('prod_10', 'Namkeen Mix 5kg', 'cat_grocery', 720, 'box', 20),
    _product('prod_11', 'Detergent Powder 5kg', 'cat_grocery', 540, 'box', 28),
    _product('prod_12', 'Bathing Soap (72 pack)', 'cat_cosmetics', 860, 'box', 22),
    _product('prod_13', 'Tea Powder 1kg', 'cat_tea', 420, 'kg', 38),
    _product('prod_14', 'Instant Coffee 200g', 'cat_grocery', 340, 'piece', 26),
    _product('prod_15', 'Tata Salt Iodized (24 x 1kg Box)', 'cat_grocery', 580, 'box', 42),
    _product('prod_16', 'Sugar 25kg', 'cat_grocery', 1320, 'box', 30),
    ..._kNewProducts,
    ..._kMoreProducts,
];
