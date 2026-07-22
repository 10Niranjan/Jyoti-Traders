import '../../entities/product_entity.dart';
import '../../repositories/product_repository.dart';

class UpdateProductUseCase {
  final ProductRepository _repository;

  UpdateProductUseCase(this._repository);

  Future<void> call(ProductEntity product) {
    return _repository.updateProduct(product);
  }
}
