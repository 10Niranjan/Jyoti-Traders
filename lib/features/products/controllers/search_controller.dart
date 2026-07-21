import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/datasources/local_storage_service.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/usecases/product/search_products_usecase.dart';

class SearchState {
  final String query;
  final List<ProductEntity> results;
  final bool isLoading;
  final List<String> recentSearches;

  const SearchState({
    this.query = '',
    this.results = const [],
    this.isLoading = false,
    this.recentSearches = const [],
  });

  SearchState copyWith({
    String? query,
    List<ProductEntity>? results,
    bool? isLoading,
    List<String>? recentSearches,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      recentSearches: recentSearches ?? this.recentSearches,
    );
  }
}

class SearchController extends StateNotifier<SearchState> {
  final SearchProductsUseCase _searchUseCase;
  final LocalStorageService _localStorage;
  Timer? _debounce;

  static const int _maxRecentSearches = 5;

  SearchController(this._searchUseCase, this._localStorage)
      : super(SearchState(recentSearches: _recentSearches(_localStorage)));

  static List<String> _recentSearches(LocalStorageService storage) {
    return storage.getRecentSearches().take(_maxRecentSearches).toList();
  }

  void onQueryChanged(String query) {
    state = state.copyWith(query: query);
    _debounce?.cancel();

    if (query.trim().isEmpty) {
      state = state.copyWith(results: [], isLoading: false);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(query));
  }

  Future<void> _search(String query) async {
    state = state.copyWith(isLoading: true);
    try {
      final results = await _searchUseCase(query);
      state = state.copyWith(results: results, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, results: []);
    }
  }

  Future<void> commitToRecentSearches(String query) async {
    if (query.trim().isEmpty) return;
    await _localStorage.addRecentSearch(query.trim());
    state = state.copyWith(recentSearches: _recentSearches(_localStorage));
  }

  Future<void> clearRecentSearches() async {
    await _localStorage.clearRecentSearches();
    state = state.copyWith(recentSearches: []);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

final searchControllerProvider = StateNotifierProvider.autoDispose<SearchController, SearchState>((ref) {
  final useCase = SearchProductsUseCase(ref.watch(productRepositoryProvider));
  final localStorage = ref.watch(localStorageProvider);
  return SearchController(useCase, localStorage);
});
