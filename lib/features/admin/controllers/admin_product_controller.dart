import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/image_upload_service.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/usecases/product/create_product_usecase.dart';
import '../../../domain/usecases/product/delete_product_usecase.dart';
import '../../../domain/usecases/product/get_all_products_usecase.dart';
import '../../../domain/usecases/product/update_product_usecase.dart';

final imageUploadServiceProvider = Provider<ImageUploadService>((ref) => ImageUploadService());

/// Every product including inactive ones — the admin list must be able to
/// see and re-activate what it deactivated, unlike retailer browsing.
final allProductsProvider = StreamProvider.autoDispose<List<ProductEntity>>((ref) {
  final useCase = GetAllProductsUseCase(ref.watch(productRepositoryProvider));
  return useCase();
});

/// Single product for the edit form, derived from the list stream rather
/// than a separate fetch — the admin always arrives here from that list.
final adminProductByIdProvider = Provider.autoDispose.family<AsyncValue<ProductEntity?>, String>((ref, productId) {
  return ref.watch(allProductsProvider).whenData(
        (products) {
          final idx = products.indexWhere((p) => p.id == productId);
          return idx == -1 ? null : products[idx];
        },
      );
});

class AdminProductController extends StateNotifier<AsyncValue<void>> {
  final CreateProductUseCase _createUseCase;
  final UpdateProductUseCase _updateUseCase;
  final DeleteProductUseCase _deleteUseCase;
  final ImageUploadService _imageUploadService;

  AdminProductController(
    this._createUseCase,
    this._updateUseCase,
    this._deleteUseCase,
    this._imageUploadService,
  ) : super(const AsyncValue.data(null));

  /// [localImagePath] is the freshly-picked file, if any — uploaded first so
  /// the resulting URL is what gets persisted on the product.
  Future<bool> create(ProductEntity product, {String? localImagePath}) {
    return _save(product, localImagePath: localImagePath, isNew: true);
  }

  Future<bool> update(ProductEntity product, {String? localImagePath}) {
    return _save(product, localImagePath: localImagePath, isNew: false);
  }

  Future<bool> _save(ProductEntity product, {String? localImagePath, required bool isNew}) async {
    state = const AsyncValue.loading();
    try {
      var toSave = product;
      if (localImagePath != null) {
        final imageUrl = await _imageUploadService.uploadProductImage(
          productId: product.id,
          localFilePath: localImagePath,
        );
        toSave = product.copyWith(imageUrl: imageUrl);
      }

      await (isNew ? _createUseCase(toSave) : _updateUseCase(toSave));
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> delete(String productId) async {
    state = const AsyncValue.loading();
    try {
      await _deleteUseCase(productId);
      await _imageUploadService.deleteProductImage(productId);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final adminProductControllerProvider =
    StateNotifierProvider.autoDispose<AdminProductController, AsyncValue<void>>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return AdminProductController(
    CreateProductUseCase(repository),
    UpdateProductUseCase(repository),
    DeleteProductUseCase(repository),
    ref.watch(imageUploadServiceProvider),
  );
});
