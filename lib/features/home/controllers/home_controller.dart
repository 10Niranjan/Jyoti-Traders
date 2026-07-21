import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/usecases/category/get_categories_usecase.dart';

final categoriesProvider = StreamProvider.autoDispose<List<CategoryEntity>>((ref) {
  final useCase = GetCategoriesUseCase(ref.watch(categoryRepositoryProvider));
  return useCase();
});
