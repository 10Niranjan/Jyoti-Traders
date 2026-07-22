import '../../entities/category_entity.dart';
import '../../repositories/category_repository.dart';

class UpdateCategoryUseCase {
  final CategoryRepository _repository;

  UpdateCategoryUseCase(this._repository);

  Future<void> call(CategoryEntity category) {
    return _repository.updateCategory(category);
  }
}
