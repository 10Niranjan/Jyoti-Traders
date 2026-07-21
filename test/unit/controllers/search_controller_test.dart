import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:traders_retailer/data/datasources/local_storage_service.dart';
import 'package:traders_retailer/domain/repositories/product_repository.dart';
import 'package:traders_retailer/domain/usecases/product/search_products_usecase.dart';
import 'package:traders_retailer/features/products/controllers/search_controller.dart';

class MockProductRepository extends Mock implements ProductRepository {}

class MockLocalStorageService extends Mock implements LocalStorageService {}

void main() {
  late MockProductRepository productRepository;
  late MockLocalStorageService localStorage;

  SearchController buildController() {
    return SearchController(SearchProductsUseCase(productRepository), localStorage);
  }

  setUp(() {
    productRepository = MockProductRepository();
    localStorage = MockLocalStorageService();
    when(() => localStorage.addRecentSearch(any())).thenAnswer((_) async {});
    when(() => localStorage.clearRecentSearches()).thenAnswer((_) async {});
  });

  test('caps the initial recent searches at 5, most recent first', () {
    when(() => localStorage.getRecentSearches())
        .thenReturn(['rice', 'oil', 'salt', 'sugar', 'tea', 'ghee']);

    final controller = buildController();

    expect(controller.state.recentSearches, ['rice', 'oil', 'salt', 'sugar', 'tea']);
  });

  test('commitToRecentSearches saves the term and refreshes state from storage', () async {
    when(() => localStorage.getRecentSearches()).thenReturn(['rice']);
    final controller = buildController();
    when(() => localStorage.getRecentSearches())
        .thenReturn(['basmati', 'rice', 'oil', 'salt', 'sugar', 'tea']);

    await controller.commitToRecentSearches('basmati');

    verify(() => localStorage.addRecentSearch('basmati')).called(1);
    expect(controller.state.recentSearches, ['basmati', 'rice', 'oil', 'salt', 'sugar']);
  });

  test('commitToRecentSearches ignores a blank/whitespace-only term', () async {
    when(() => localStorage.getRecentSearches()).thenReturn([]);
    final controller = buildController();

    await controller.commitToRecentSearches('   ');

    verifyNever(() => localStorage.addRecentSearch(any()));
  });

  test('clearRecentSearches empties state and calls through to storage', () async {
    when(() => localStorage.getRecentSearches()).thenReturn(['rice', 'oil']);
    final controller = buildController();

    await controller.clearRecentSearches();

    verify(() => localStorage.clearRecentSearches()).called(1);
    expect(controller.state.recentSearches, isEmpty);
  });

  test('a blank query clears results immediately without hitting the repository', () {
    when(() => localStorage.getRecentSearches()).thenReturn([]);
    final controller = buildController();

    controller.onQueryChanged('   ');

    expect(controller.state.results, isEmpty);
    expect(controller.state.isLoading, isFalse);
    verifyNever(() => productRepository.searchProducts(any()));
  });
}
