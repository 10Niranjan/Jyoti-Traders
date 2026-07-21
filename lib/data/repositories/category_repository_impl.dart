import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/remote/category_remote_datasource.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDatasource _remote;

  CategoryRepositoryImpl(this._remote);

  @override
  Stream<List<CategoryEntity>> watchCategories() {
    return _remote.watchCategories().map((list) => list.map((m) => m.toEntity()).toList());
  }

  @override
  Future<void> createCategory(CategoryEntity category) {
    return _remote.createCategory(CategoryModel.fromEntity(category));
  }

  @override
  Future<void> updateCategory(CategoryEntity category) {
    return _remote.updateCategory(CategoryModel.fromEntity(category));
  }

  @override
  Future<void> deleteCategory(String categoryId) {
    return _remote.deleteCategory(categoryId);
  }
}
