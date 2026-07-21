import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/local/product_local_datasource.dart';
import '../datasources/remote/product_remote_datasource.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDatasource _remote;
  final ProductLocalDatasource _local;

  ProductRepositoryImpl(this._remote, this._local);

  @override
  Stream<List<ProductEntity>> watchProducts({String? categoryId}) {
    return _remote.watchProducts(categoryId: categoryId).map((list) {
      // Cache the unfiltered "all products" view for offline browsing.
      if (categoryId == null) {
        _local.cacheCatalog(list);
      }
      return list.map((m) => m.toEntity()).toList();
    });
  }

  @override
  Future<List<ProductEntity>> searchProducts(String query) async {
    final results = await _remote.searchProducts(query);
    return results.map((m) => m.toEntity()).toList();
  }

  @override
  Future<ProductEntity?> getProductById(String productId) async {
    final model = await _remote.getProductById(productId);
    return model?.toEntity();
  }

  @override
  Future<void> createProduct(ProductEntity product) {
    return _remote.createProduct(ProductModel.fromEntity(product));
  }

  @override
  Future<void> updateProduct(ProductEntity product) {
    return _remote.updateProduct(ProductModel.fromEntity(product));
  }

  @override
  Future<void> deleteProduct(String productId) {
    return _remote.deleteProduct(productId);
  }
}
