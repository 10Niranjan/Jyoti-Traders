import '../../entities/product_entity.dart';
import '../../repositories/product_repository.dart';

/// Admin-side product listing — includes inactive products.
class GetAllProductsUseCase {
  final ProductRepository _repository;

  GetAllProductsUseCase(this._repository);

  Stream<List<ProductEntity>> call() {
    return _repository.watchAllProducts();
  }
}
