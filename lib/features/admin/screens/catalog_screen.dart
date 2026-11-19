import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/route_names.dart';
import '../../../l10n/app_localizations.dart';
import 'manage_categories_screen.dart';
import 'manage_products_screen.dart';

/// Admin "Catalog" tab (Phase 9.4) — Products and Categories folded into one
/// destination via a segmented `TabBar`, reusing the exact same
/// list bodies ([ProductsListView], [CategoriesListView]) their standalone
/// screens already use, so nothing about their behavior changes.
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // The FAB (Add Product / Add Category) depends on which tab is active,
    // so it needs its own rebuild whenever the tab changes.
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unselectedColor = Theme.of(
      context,
    ).colorScheme.onSurface.withOpacity(0.6);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.adminCatalogTitle,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_tabController.index == 0)
            IconButton(
              icon: const Icon(Icons.upload_file_outlined),
              tooltip: l10n.adminBulkImportTooltip,
              onPressed: () => context.push(RouteNames.adminBulkImportProducts),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: unselectedColor,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(
              icon: const Icon(Icons.inventory_2_outlined),
              text: l10n.adminProductsTab,
            ),
            Tab(
              icon: const Icon(Icons.category_outlined),
              text: l10n.adminCategoriesTab,
            ),
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 0
          ? const AddProductFab()
          : const AddCategoryFab(),
      body: TabBarView(
        controller: _tabController,
        children: const [ProductsListView(), CategoriesListView()],
      ),
    );
  }
}
