import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/product_sort.dart';
import '../../../data/datasources/local_storage_service.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/usecases/product/search_products_usecase.dart';

class SearchState {
  final String query;
  final List<ProductEntity> results;
  final bool isLoading;
  final bool hasError;
  final List<String> recentSearches;
  final ProductSort sort;
  final bool inStockOnly;

  const SearchState({
    this.query = '',
    this.results = const [],
    this.isLoading = false,
    this.hasError = false,
    this.recentSearches = const [],
    this.sort = ProductSort.relevance,
    this.inStockOnly = false,
  });

  /// What the screen actually renders — [results] as fetched, with [sort]
  /// and [inStockOnly] applied client-side. Kept as a derived getter rather
  /// than a stored field so there's only one source of truth for the raw
  /// results and no risk of the two drifting out of sync.
  List<ProductEntity> get visibleResults =>
      sortAndFilterProducts(results, sort: sort, inStockOnly: inStockOnly);

  SearchState copyWith({
    String? query,
    List<ProductEntity>? results,
    bool? isLoading,
    bool? hasError,
    List<String>? recentSearches,
    ProductSort? sort,
    bool? inStockOnly,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      recentSearches: recentSearches ?? this.recentSearches,
      sort: sort ?? this.sort,
      inStockOnly: inStockOnly ?? this.inStockOnly,
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
      state = state.copyWith(results: [], isLoading: false, hasError: false);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(query));
  }

  /// Re-runs the last search — used by the error state's retry action and by
  /// pull-to-refresh, since search results aren't backed by a Riverpod
  /// provider that `ref.invalidate` could restart. Returns the in-flight
  /// future so `RefreshIndicator` keeps its spinner up until it resolves.
  Future<void> retry() {
    if (state.query.trim().isEmpty) return Future.value();
    return _search(state.query);
  }

  Future<void> _search(String query) async {
    state = state.copyWith(isLoading: true, hasError: false);
    try {
      final results = await _searchUseCase(query);
      state = state.copyWith(
        results: results,
        isLoading: false,
        hasError: false,
      );
      // Previously only saved on pressing Enter or tapping a result — so
      // typing a query, reading the auto-search results, then just going
      // back never left a trace in Recent Searches. Saving here, once the
      // debounce has already settled on a query the retailer paused on,
      // covers every exit path.
      await commitToRecentSearches(query);
    } catch (e) {
      state = state.copyWith(isLoading: false, hasError: true, results: []);
    }
  }

  void setSort(ProductSort sort) => state = state.copyWith(sort: sort);

  void setInStockOnly(bool value) => state = state.copyWith(inStockOnly: value);

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

final searchControllerProvider =
    StateNotifierProvider.autoDispose<SearchController, SearchState>((ref) {
      final useCase = SearchProductsUseCase(
        ref.watch(productRepositoryProvider),
      );
      final localStorage = ref.watch(localStorageProvider);
      return SearchController(useCase, localStorage);
    });
