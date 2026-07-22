import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/image_upload_service.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/usecases/category/create_category_usecase.dart';
import '../../../domain/usecases/category/delete_category_usecase.dart';
import '../../../domain/usecases/category/get_categories_usecase.dart';
import '../../../domain/usecases/category/update_category_usecase.dart';
import 'admin_product_controller.dart' show imageUploadServiceProvider;

/// Admin's category list — same `watchCategories()` stream retailers use
/// (unlike products, it was never `isActive`-filtered, so there's no
/// separate "all categories" query needed here).
final adminCategoriesProvider = StreamProvider.autoDispose<List<CategoryEntity>>((ref) {
  final useCase = GetCategoriesUseCase(ref.watch(categoryRepositoryProvider));
  return useCase();
});

/// Single category for the edit form, derived from the list stream rather
/// than a separate fetch — the admin always arrives here from that list.
final adminCategoryByIdProvider = Provider.autoDispose.family<AsyncValue<CategoryEntity?>, String>((ref, categoryId) {
  return ref.watch(adminCategoriesProvider).whenData(
        (categories) {
          final idx = categories.indexWhere((c) => c.id == categoryId);
          return idx == -1 ? null : categories[idx];
        },
      );
});

class AdminCategoryController extends StateNotifier<AsyncValue<void>> {
  final CreateCategoryUseCase _createUseCase;
  final UpdateCategoryUseCase _updateUseCase;
  final DeleteCategoryUseCase _deleteUseCase;
  final ImageUploadService _imageUploadService;

  AdminCategoryController(
    this._createUseCase,
    this._updateUseCase,
    this._deleteUseCase,
    this._imageUploadService,
  ) : super(const AsyncValue.data(null));

  /// [localIconPath] is the freshly-picked file, if any — uploaded first so
  /// the resulting URL is what gets persisted on the category.
  Future<bool> create(CategoryEntity category, {String? localIconPath}) {
    return _save(category, localIconPath: localIconPath, isNew: true);
  }

  Future<bool> update(CategoryEntity category, {String? localIconPath}) {
    return _save(category, localIconPath: localIconPath, isNew: false);
  }

  Future<bool> _save(CategoryEntity category, {String? localIconPath, required bool isNew}) async {
    state = const AsyncValue.loading();
    try {
      var toSave = category;
      if (localIconPath != null) {
        final iconUrl = await _imageUploadService.uploadCategoryIcon(
          categoryId: category.id,
          localFilePath: localIconPath,
        );
        toSave = category.copyWith(iconUrl: iconUrl);
      }

      await (isNew ? _createUseCase(toSave) : _updateUseCase(toSave));
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> delete(String categoryId) async {
    state = const AsyncValue.loading();
    try {
      await _deleteUseCase(categoryId);
      await _imageUploadService.deleteCategoryIcon(categoryId);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Persists a drag-to-reorder result — [reordered] is the full category
  /// list in its new display order. Only categories whose `displayOrder`
  /// actually changed get written, since most drags only move a couple of
  /// items past each other.
  Future<bool> reorder(List<CategoryEntity> reordered) async {
    state = const AsyncValue.loading();
    try {
      for (var i = 0; i < reordered.length; i++) {
        if (reordered[i].displayOrder != i) {
          await _updateUseCase(reordered[i].copyWith(displayOrder: i));
        }
      }
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final adminCategoryControllerProvider =
    StateNotifierProvider.autoDispose<AdminCategoryController, AsyncValue<void>>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return AdminCategoryController(
    CreateCategoryUseCase(repository),
    UpdateCategoryUseCase(repository),
    DeleteCategoryUseCase(repository),
    ref.watch(imageUploadServiceProvider),
  );
});
