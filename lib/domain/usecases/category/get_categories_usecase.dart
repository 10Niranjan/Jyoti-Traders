import '../../entities/category_entity.dart';
import '../../repositories/category_repository.dart';

class GetCategoriesUseCase {
  final CategoryRepository _repository;

  GetCategoriesUseCase(this._repository);

  Stream<List<CategoryEntity>> call() {
    return _repository.watchCategories();
  }
}
