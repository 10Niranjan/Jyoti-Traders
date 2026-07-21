import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/hive_keys.dart';
import '../../models/product_model.dart';

/// Caches the last-fetched product catalog for offline browsing (PRD §11 —
/// ordering itself still requires a connection, only browsing is cached).
class ProductLocalDatasource {
  final Box _catalogBox;

  ProductLocalDatasource({required Box catalogBox}) : _catalogBox = catalogBox;

  List<ProductModel> getCachedCatalog() {
    final List<dynamic> raw = _catalogBox.get(HiveKeys.cachedProductCatalog, defaultValue: []);
    return raw.map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<void> cacheCatalog(List<ProductModel> products) async {
    await _catalogBox.put(
      HiveKeys.cachedProductCatalog,
      products.map((p) => p.toJson()).toList(),
    );
  }
}
