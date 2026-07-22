import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/usecases/category/get_categories_usecase.dart';

/// Retailer-facing category list — active only. Admin's equivalent,
/// `adminCategoriesProvider`, watches the same unfiltered stream since it
/// needs to show (and re-activate) inactive categories too.
final categoriesProvider = StreamProvider.autoDispose<List<CategoryEntity>>((ref) {
  final useCase = GetCategoriesUseCase(ref.watch(categoryRepositoryProvider));
  return useCase().map((list) => list.where((c) => c.isActive).toList());
});
