import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/route_names.dart';
import '../../../core/utils/admin_product_filter.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/value_objects/money.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import '../controllers/admin_category_controller.dart';
import '../controllers/admin_product_controller.dart';
import '../widgets/admin_product_tile.dart';

/// Standalone screen at `/admin/products` — no longer linked to from
/// anywhere in-app since the Catalog tab (Phase 9.4) embeds [ProductsListView]
/// directly, but left in place (route + screen) as a working direct link.
class ManageProductsScreen extends StatelessWidget {
  const ManageProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.adminManageProductsTitle,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: const AddProductFab(),
      body: const ProductsListView(),
    );
  }
}

/// True while the admin has entered multi-select mode on the Products list.
/// Read by [AddProductFab] — which lives on a different Scaffold than
/// [ProductsListView] itself (either [ManageProductsScreen] or the Catalog
/// tab) — so the FAB can get out of the way of the bulk-edit action bar,
/// which floats in the same bottom-right corner a `Scaffold` FAB does.
final productSelectionModeProvider = StateProvider.autoDispose<bool>(
  (ref) => false,
);

/// Public so [CatalogScreen] (Phase 9.4) can also use it as the Products
/// segment's FAB.
class AddProductFab extends ConsumerWidget {
  const AddProductFab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(productSelectionModeProvider)) return const SizedBox.shrink();
    return FloatingActionButton.extended(
      onPressed: () => context.push(RouteNames.adminAddProduct),
      icon: const Icon(Icons.add_rounded),
      label: Text(AppLocalizations.of(context)!.adminAddProduct),
    );
  }
}

/// The product list itself — no `Scaffold`/`AppBar`/FAB of its own, so it can
/// be embedded either inside [ManageProductsScreen] or, since Phase 9.4, as
/// one segment of the admin Catalog tab.
class ProductsListView extends ConsumerStatefulWidget {
  const ProductsListView({super.key});

  @override
  ConsumerState<ProductsListView> createState() => _ProductsListViewState();
}

class _ProductsListViewState extends ConsumerState<ProductsListView> {
  final _searchController = TextEditingController();
  String _query = '';
  String? _categoryId;
  AdminProductSort _sort = AdminProductSort.nameAsc;

  bool _selectionMode = false;
  final Set<String> _selectedIds = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSelectionMode() {
    setState(() {
      _selectionMode = !_selectionMode;
      _selectedIds.clear();
    });
    ref.read(productSelectionModeProvider.notifier).state = _selectionMode;
  }

  Future<void> _showBulkEditDialog(List<ProductEntity> selected) async {
    // The dialog owns and disposes its own controllers via its own State —
    // disposing them here instead, right after the `await` returns, would
    // race the dialog's own closing transition (still rendering for one more
    // frame) and throw "used after being disposed".
    final result = await showDialog<({int? stock, double? priceAdjustPercent})>(
      context: context,
      builder: (_) => _BulkEditDialogContent(count: selected.length),
    );

    if (result == null || !mounted) return;
    if (result.stock == null && result.priceAdjustPercent == null) {
      return; // nothing to apply
    }

    final successCount = await ref
        .read(adminProductControllerProvider.notifier)
        .bulkUpdate(
          selected,
          (product) => product.copyWith(
            stock: result.stock,
            price: result.priceAdjustPercent == null
                ? null
                : Money(
                    product.price.amount *
                        (1 + result.priceAdjustPercent! / 100),
                  ),
          ),
        );
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(
            context,
          )!.adminBulkEditResult(successCount, selected.length),
        ),
        backgroundColor: successCount == selected.length
            ? AppColors.success
            : AppColors.warning,
        behavior: SnackBarBehavior.floating,
      ),
    );
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
    ref.read(productSelectionModeProvider.notifier).state = false;
  }

  Future<void> _confirmDelete(ProductEntity product) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          l10n.adminDeleteProductTitle,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        content: Text(
          l10n.adminDeleteProductContent(product.name),
          style: GoogleFonts.inter(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.adminCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n.adminDelete,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final success = await ref
        .read(adminProductControllerProvider.notifier)
        .delete(product.id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? l10n.adminProductDeletedMessage(product.name)
              : l10n.adminDeleteFailed(
                  '${ref.read(adminProductControllerProvider).error}',
                ),
        ),
        backgroundColor: success ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(allProductsProvider);
    final categoriesAsync = ref.watch(adminCategoriesProvider);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.adminSearchProducts,
                  isDense: true,
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          tooltip: l10n.adminClearSearchTooltip,
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: categoriesAsync.maybeWhen(
                      data: (categories) => _CategoryDropdown(
                        categories: categories,
                        value: _categoryId,
                        onChanged: (id) => setState(() => _categoryId = id),
                      ),
                      orElse: () => const SizedBox.shrink(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SortDropdown(
                      value: _sort,
                      onChanged: (sort) => setState(() => _sort = sort),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _toggleSelectionMode,
                  icon: Icon(
                    _selectionMode
                        ? Icons.close_rounded
                        : Icons.checklist_rounded,
                    size: 18,
                  ),
                  label: Text(
                    _selectionMode ? l10n.adminCancel : l10n.adminSelect,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => ref.invalidate(allProductsProvider),
            child: products.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(18.0),
                child: ListShimmerLoader(itemCount: 6, itemHeight: 92),
              ),
              error: (e, _) => ListView(
                padding: const EdgeInsets.all(18.0),
                children: [
                  ErrorStateWidget(
                    message: l10n.adminCouldntLoadProducts('$e'),
                    onRetry: () => ref.invalidate(allProductsProvider),
                  ),
                ],
              ),
              data: (list) {
                if (list.isEmpty) {
                  return ListView(
                    padding: const EdgeInsets.all(18.0),
                    children: [
                      EmptyStateWidget(
                        icon: Icons.inventory_2_outlined,
                        title: l10n.adminNoProductsYetTitle,
                        message: l10n.adminNoProductsYetMessage,
                      ),
                    ],
                  );
                }

                final filtered = filterAndSortAdminProducts(
                  list,
                  query: _query,
                  categoryId: _categoryId,
                  sort: _sort,
                );

                if (filtered.isEmpty) {
                  return ListView(
                    padding: const EdgeInsets.all(18.0),
                    children: [
                      EmptyStateWidget(
                        icon: Icons.search_off_rounded,
                        title: l10n.adminNoProductsMatchTitle,
                        message: l10n.adminNoProductsMatchMessage,
                      ),
                    ],
                  );
                }

                // Low-stock count reflects the whole catalog, not just the
                // current search/filter — it's a catalog-health summary, not
                // scoped to whatever the admin happens to be searching for.
                final lowStockCount = list
                    .where((p) => p.stock <= AppConstants.kLowStockThreshold)
                    .length;

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(18, 10, 18, 88),
                        itemCount:
                            filtered.length + (lowStockCount > 0 ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (lowStockCount > 0 && index == 0) {
                            return _LowStockBanner(count: lowStockCount);
                          }
                          final product =
                              filtered[index - (lowStockCount > 0 ? 1 : 0)];
                          final tile = AdminProductTile(
                            product: product,
                            onEdit: () => context.push(
                              RouteNames.adminEditProductPath(product.id),
                            ),
                            onDelete: () => _confirmDelete(product),
                          );
                          if (!_selectionMode) return tile;
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: _selectedIds.contains(product.id),
                                onChanged: (checked) => setState(() {
                                  if (checked == true) {
                                    _selectedIds.add(product.id);
                                  } else {
                                    _selectedIds.remove(product.id);
                                  }
                                }),
                              ),
                              Expanded(child: tile),
                            ],
                          );
                        },
                      ),
                    ),
                    if (_selectionMode && _selectedIds.isNotEmpty)
                      _BulkActionBar(
                        count: _selectedIds.length,
                        onEdit: () => _showBulkEditDialog(
                          list
                              .where((p) => _selectedIds.contains(p.id))
                              .toList(),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Content of the bulk-edit dialog — a `StatefulWidget` so its
/// `TextEditingController`s follow the dialog route's own lifecycle instead
/// of being disposed by the caller right after `showDialog` returns, which
/// races the dialog's closing animation.
class _BulkEditDialogContent extends StatefulWidget {
  final int count;

  const _BulkEditDialogContent({required this.count});

  @override
  State<_BulkEditDialogContent> createState() => _BulkEditDialogContentState();
}

class _BulkEditDialogContentState extends State<_BulkEditDialogContent> {
  final _stockController = TextEditingController();
  final _priceAdjustController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _stockController.dispose();
    _priceAdjustController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(
        l10n.adminBulkEditTitle(widget.count),
        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 17),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.adminBulkEditHint,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _stockController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.adminSetStockTo),
              validator: (v) =>
                  (v != null && v.isNotEmpty && int.tryParse(v) == null)
                  ? l10n.adminEnterWholeNumber
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _priceAdjustController,
              keyboardType: const TextInputType.numberWithOptions(
                signed: true,
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: l10n.adminAdjustPriceByPercent,
                hintText: l10n.adminAdjustPriceHint,
              ),
              validator: (v) =>
                  (v != null && v.isNotEmpty && double.tryParse(v) == null)
                  ? l10n.adminEnterNumber
                  : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.adminCancel),
        ),
        TextButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.of(context).pop((
              stock: int.tryParse(_stockController.text),
              priceAdjustPercent: double.tryParse(_priceAdjustController.text),
            ));
          },
          child: Text(l10n.adminApply),
        ),
      ],
    );
  }
}

/// Sticky bottom bar shown while at least one product is checked in
/// selection mode — "N selected" plus the single action a bulk selection
/// currently supports.
class _BulkActionBar extends StatelessWidget {
  final int count;
  final VoidCallback onEdit;

  const _BulkActionBar({required this.count, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        border: const Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.adminSelectedCount(count),
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: Text(l10n.adminBulkEdit),
          ),
        ],
      ),
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  final List<CategoryEntity> categories;
  final String? value;
  final ValueChanged<String?> onChanged;

  const _CategoryDropdown({
    required this.categories,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String?>(
      initialValue: value,
      isExpanded: true,
      isDense: true,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: [
        DropdownMenuItem(
          value: null,
          child: Text(AppLocalizations.of(context)!.adminAllCategories),
        ),
        for (final category in categories)
          DropdownMenuItem(value: category.id, child: Text(category.name)),
      ],
      onChanged: onChanged,
    );
  }
}

class _SortDropdown extends StatelessWidget {
  final AdminProductSort value;
  final ValueChanged<AdminProductSort> onChanged;

  const _SortDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<AdminProductSort>(
      initialValue: value,
      isExpanded: true,
      isDense: true,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: [
        DropdownMenuItem(
          value: AdminProductSort.nameAsc,
          child: Text(AppLocalizations.of(context)!.adminSortNameAZ),
        ),
        DropdownMenuItem(
          value: AdminProductSort.stockLowToHigh,
          child: Text(AppLocalizations.of(context)!.adminSortStockLow),
        ),
        DropdownMenuItem(
          value: AdminProductSort.priceLowToHigh,
          child: Text(AppLocalizations.of(context)!.adminSortPriceLow),
        ),
        DropdownMenuItem(
          value: AdminProductSort.priceHighToLow,
          child: Text(AppLocalizations.of(context)!.adminSortPriceHigh),
        ),
      ],
      onChanged: (sort) {
        if (sort != null) onChanged(sort);
      },
    );
  }
}

class _LowStockBanner extends StatelessWidget {
  final int count;

  const _LowStockBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppLocalizations.of(
                context,
              )!.adminLowStockBanner(count, AppConstants.kLowStockThreshold),
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
