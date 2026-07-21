import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/usecases/product/get_products_usecase.dart';

final productsByCategoryProvider =
    StreamProvider.autoDispose.family<List<ProductEntity>, String>((ref, categoryId) {
  final useCase = GetProductsUseCase(ref.watch(productRepositoryProvider));
  return useCase(categoryId: categoryId);
});

final productByIdProvider = FutureProvider.autoDispose.family<ProductEntity?, String>((ref, productId) {
  return ref.watch(productRepositoryProvider).getProductById(productId);
});
