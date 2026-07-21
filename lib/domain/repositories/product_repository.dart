import '../entities/product_entity.dart';

abstract class ProductRepository {
  Stream<List<ProductEntity>> watchProducts({String? categoryId});

  Future<List<ProductEntity>> searchProducts(String query);

  Future<ProductEntity?> getProductById(String productId);

  Future<void> createProduct(ProductEntity product);

  Future<void> updateProduct(ProductEntity product);

  Future<void> deleteProduct(String productId);
}
