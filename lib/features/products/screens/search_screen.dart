import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/route_names.dart';
import '../../../domain/entities/cart_item_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import '../../cart/controllers/cart_controller.dart';
import '../controllers/search_controller.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchControllerProvider);
    final notifier = ref.read(searchControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search products...',
            border: InputBorder.none,
          ),
          onChanged: notifier.onQueryChanged,
          onSubmitted: notifier.commitToRecentSearches,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: state.query.trim().isEmpty
            ? _RecentSearches(
                terms: state.recentSearches,
                onTapTerm: (term) {
                  _controller.text = term;
                  notifier.onQueryChanged(term);
                },
                onClear: notifier.clearRecentSearches,
              )
            : _SearchResults(
                isLoading: state.isLoading,
                results: state.results,
                onResultTap: (product) {
                  notifier.commitToRecentSearches(state.query);
                  context.push(RouteNames.productDetailPath(product.id));
                },
              ),
      ),
    );
  }
}

class _RecentSearches extends StatelessWidget {
  final List<String> terms;
  final ValueChanged<String> onTapTerm;
  final VoidCallback onClear;

  const _RecentSearches({required this.terms, required this.onTapTerm, required this.onClear});

  @override
  Widget build(BuildContext context) {
    if (terms.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.search_rounded,
        title: 'Search for products',
        message: 'Try a product name like "rice" or "oil".',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Searches', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            TextButton(onPressed: onClear, child: const Text('Clear')),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: terms
              .map((term) => ActionChip(
                    label: Text(term),
                    onPressed: () => onTapTerm(term),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _SearchResults extends StatelessWidget {
  final bool isLoading;
  final List<ProductEntity> results;
  final ValueChanged<ProductEntity> onResultTap;

  const _SearchResults({required this.isLoading, required this.results, required this.onResultTap});

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const ListShimmerLoader(itemCount: 5);
    if (results.isEmpty) {
      return const EmptyStateWidget(icon: Icons.search_off_rounded, title: 'No products found');
    }
    return Consumer(
      builder: (context, ref, _) => ListView.separated(
        itemCount: results.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final product = results[index];
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary),
            ),
            title: Text(product.name),
            subtitle: Text(product.price.formatted),
            trailing: IconButton(
              icon: const Icon(Icons.add_shopping_cart_outlined),
              onPressed: () => ref.read(cartControllerProvider.notifier).addItem(
                    CartItemEntity(
                      productId: product.id,
                      name: product.name,
                      imageUrl: product.imageUrl,
                      unitPrice: product.price,
                      unit: product.unit,
                      qty: 1,
                    ),
                  ),
            ),
            onTap: () => onResultTap(product),
          );
        },
      ),
    );
  }
}
