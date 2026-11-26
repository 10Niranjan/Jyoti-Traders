import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:traders_retailer/core/utils/product_sort.dart';
import 'package:traders_retailer/data/datasources/local_storage_service.dart';
import 'package:traders_retailer/domain/entities/product_entity.dart';
import 'package:traders_retailer/domain/repositories/product_repository.dart';
import 'package:traders_retailer/domain/usecases/product/search_products_usecase.dart';
import 'package:traders_retailer/domain/value_objects/money.dart';
import 'package:traders_retailer/features/products/controllers/search_controller.dart';

class MockProductRepository extends Mock implements ProductRepository {}

class MockLocalStorageService extends Mock implements LocalStorageService {}

void main() {
  late MockProductRepository productRepository;
  late MockLocalStorageService localStorage;

  SearchController buildController() {
    return SearchController(
      SearchProductsUseCase(productRepository),
      localStorage,
    );
  }

  setUp(() {
    productRepository = MockProductRepository();
    localStorage = MockLocalStorageService();
    when(() => localStorage.addRecentSearch(any())).thenAnswer((_) async {});
    when(() => localStorage.clearRecentSearches()).thenAnswer((_) async {});
  });

  test('caps the initial recent searches at 5, most recent first', () {
    when(
      () => localStorage.getRecentSearches(),
    ).thenReturn(['rice', 'oil', 'salt', 'sugar', 'tea', 'ghee']);

    final controller = buildController();

    expect(controller.state.recentSearches, [
      'rice',
      'oil',
      'salt',
      'sugar',
      'tea',
    ]);
  });

  test(
    'commitToRecentSearches saves the term and refreshes state from storage',
    () async {
      when(() => localStorage.getRecentSearches()).thenReturn(['rice']);
      final controller = buildController();
      when(
        () => localStorage.getRecentSearches(),
      ).thenReturn(['basmati', 'rice', 'oil', 'salt', 'sugar', 'tea']);

      await controller.commitToRecentSearches('basmati');

      verify(() => localStorage.addRecentSearch('basmati')).called(1);
      expect(controller.state.recentSearches, [
        'basmati',
        'rice',
        'oil',
        'salt',
        'sugar',
      ]);
    },
  );

  test('commitToRecentSearches ignores a blank/whitespace-only term', () async {
    when(() => localStorage.getRecentSearches()).thenReturn([]);
    final controller = buildController();

    await controller.commitToRecentSearches('   ');

    verifyNever(() => localStorage.addRecentSearch(any()));
  });

  test(
    'clearRecentSearches empties state and calls through to storage',
    () async {
      when(() => localStorage.getRecentSearches()).thenReturn(['rice', 'oil']);
      final controller = buildController();

      await controller.clearRecentSearches();

      verify(() => localStorage.clearRecentSearches()).called(1);
      expect(controller.state.recentSearches, isEmpty);
    },
  );

  test(
    'a blank query clears results immediately without hitting the repository',
    () {
      when(() => localStorage.getRecentSearches()).thenReturn([]);
      final controller = buildController();

      controller.onQueryChanged('   ');

      expect(controller.state.results, isEmpty);
      expect(controller.state.isLoading, isFalse);
      verifyNever(() => productRepository.searchProducts(any()));
    },
  );

  test(
    'a repository failure sets hasError instead of silently looking like "no results"',
    () async {
      when(() => localStorage.getRecentSearches()).thenReturn([]);
      when(
        () => productRepository.searchProducts(any()),
      ).thenThrow(Exception('offline'));
      final controller = buildController();

      controller.onQueryChanged('rice');
      await Future.delayed(const Duration(milliseconds: 450));

      expect(controller.state.hasError, isTrue);
      expect(controller.state.isLoading, isFalse);
      expect(controller.state.results, isEmpty);
    },
  );

  test(
    'retry() re-runs the last query and clears the error on success',
    () async {
      when(() => localStorage.getRecentSearches()).thenReturn([]);
      when(
        () => productRepository.searchProducts(any()),
      ).thenThrow(Exception('offline'));
      final controller = buildController();

      controller.onQueryChanged('rice');
      await Future.delayed(const Duration(milliseconds: 450));
      expect(controller.state.hasError, isTrue);

      when(
        () => productRepository.searchProducts(any()),
      ).thenAnswer((_) async => []);
      await controller.retry();

      expect(controller.state.hasError, isFalse);
      verify(() => productRepository.searchProducts('rice')).called(2);
    },
  );

  test(
    'a successful search commits its query to recent searches automatically',
    () async {
      when(() => localStorage.getRecentSearches()).thenReturn([]);
      when(
        () => productRepository.searchProducts(any()),
      ).thenAnswer((_) async => []);
      final controller = buildController();

      // Covers the exit path where a retailer types, reads the debounced
      // auto-search results, then just navigates away without pressing
      // Enter or tapping a result — previously nothing would be saved.
      controller.onQueryChanged('rice');
      await Future.delayed(const Duration(milliseconds: 450));

      verify(() => localStorage.addRecentSearch('rice')).called(1);
    },
  );

  test('retry() is a no-op when there is no active query', () async {
    when(() => localStorage.getRecentSearches()).thenReturn([]);
    final controller = buildController();

    await controller.retry();

    verifyNever(() => productRepository.searchProducts(any()));
  });

  test(
    'setSort/setInStockOnly update state and visibleResults reflects them',
    () async {
      when(() => localStorage.getRecentSearches()).thenReturn([]);
      final cheap = ProductEntity(
        id: 'cheap',
        name: 'Cheap',
        categoryId: 'c1',
        imageUrl: '',
        price: Money(10),
        unit: ProductUnit.piece,
        stock: 0,
        isActive: true,
      );
      final expensive = ProductEntity(
        id: 'expensive',
        name: 'Expensive',
        categoryId: 'c1',
        imageUrl: '',
        price: Money(100),
        unit: ProductUnit.piece,
        stock: 5,
        isActive: true,
      );
      when(
        () => productRepository.searchProducts(any()),
      ).thenAnswer((_) async => [expensive, cheap]);
      final controller = buildController();

      controller.onQueryChanged('x');
      await Future.delayed(const Duration(milliseconds: 450));
      expect(controller.state.visibleResults.map((p) => p.id), [
        'expensive',
        'cheap',
      ]);

      controller.setSort(ProductSort.priceLowToHigh);
      expect(controller.state.sort, ProductSort.priceLowToHigh);
      expect(controller.state.visibleResults.map((p) => p.id), [
        'cheap',
        'expensive',
      ]);

      controller.setInStockOnly(true);
      expect(controller.state.visibleResults.map((p) => p.id), ['expensive']);
    },
  );

  test(
    'setCategory filters visibleResults and resultCategoryIds reflects the raw results',
    () async {
      when(() => localStorage.getRecentSearches()).thenReturn([]);
      final rice = ProductEntity(
        id: 'rice',
        name: 'Rice',
        categoryId: 'grains',
        imageUrl: '',
        price: Money(100),
        unit: ProductUnit.piece,
        stock: 5,
        isActive: true,
      );
      final soap = ProductEntity(
        id: 'soap',
        name: 'Soap',
        categoryId: 'staples',
        imageUrl: '',
        price: Money(50),
        unit: ProductUnit.piece,
        stock: 5,
        isActive: true,
      );
      when(
        () => productRepository.searchProducts(any()),
      ).thenAnswer((_) async => [rice, soap]);
      final controller = buildController();

      controller.onQueryChanged('x');
      await Future.delayed(const Duration(milliseconds: 450));
      expect(controller.state.resultCategoryIds, {'grains', 'staples'});

      controller.setCategory('grains');
      expect(controller.state.categoryId, 'grains');
      expect(controller.state.visibleResults.map((p) => p.id), ['rice']);

      controller.setCategory(null);
      expect(controller.state.categoryId, isNull);
      expect(controller.state.visibleResults.map((p) => p.id), [
        'rice',
        'soap',
      ]);
    },
  );

  test('a new query resets a previously-picked category filter', () async {
    when(() => localStorage.getRecentSearches()).thenReturn([]);
    when(
      () => productRepository.searchProducts(any()),
    ).thenAnswer((_) async => []);
    final controller = buildController();

    controller.onQueryChanged('rice');
    await Future.delayed(const Duration(milliseconds: 450));
    controller.setCategory('grains');
    expect(controller.state.categoryId, 'grains');

    controller.onQueryChanged('soap');
    expect(controller.state.categoryId, isNull);
  });
}
