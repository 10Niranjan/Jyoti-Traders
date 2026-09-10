import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/route_names.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import '../controllers/admin_category_controller.dart';
import '../widgets/admin_category_tile.dart';

/// Standalone screen at `/admin/categories` — no longer linked to from
/// anywhere in-app since the Catalog tab (Phase 9.4) embeds
/// [CategoriesListView] directly, but left in place (route + screen) as a
/// working direct link.
class ManageCategoriesScreen extends StatelessWidget {
  const ManageCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.adminManageCategoriesTitle,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: const AddCategoryFab(),
      body: const CategoriesListView(),
    );
  }
}

/// Public so [CatalogScreen] (Phase 9.4) can also use it as the Categories
/// segment's FAB.
class AddCategoryFab extends StatelessWidget {
  const AddCategoryFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => context.push(RouteNames.adminAddCategory),
      icon: const Icon(Icons.add_rounded),
      label: Text(AppLocalizations.of(context)!.adminAddCategory),
    );
  }
}

/// The category list itself — no `Scaffold`/`AppBar`/FAB of its own, so it
/// can be embedded either inside [ManageCategoriesScreen] or, since Phase
/// 9.4, as one segment of the admin Catalog tab.
class CategoriesListView extends ConsumerWidget {
  const CategoriesListView({super.key});

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    CategoryEntity category,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          l10n.adminDeleteCategoryTitle,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        content: Text(
          l10n.adminDeleteCategoryContent(category.name),
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
    if (confirmed != true || !context.mounted) return;

    final success = await ref
        .read(adminCategoryControllerProvider.notifier)
        .delete(category.id);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? l10n.adminCategoryDeletedMessage(category.name)
              : l10n.adminDeleteFailed(
                  '${ref.read(adminCategoryControllerProvider).error}',
                ),
        ),
        backgroundColor: success ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(adminCategoriesProvider);
    final l10n = AppLocalizations.of(context)!;

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(adminCategoriesProvider),
      child: categories.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(18.0),
          child: ListShimmerLoader(itemCount: 6, itemHeight: 72),
        ),
        error: (e, _) => ListView(
          padding: const EdgeInsets.all(18.0),
          children: [
            ErrorStateWidget(
              message: l10n.adminCouldntLoadCategories('$e'),
              onRetry: () => ref.invalidate(adminCategoriesProvider),
            ),
          ],
        ),
        data: (list) {
          if (list.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(18.0),
              children: [
                EmptyStateWidget(
                  icon: Icons.category_outlined,
                  title: l10n.adminNoCategoriesYetTitle,
                  message: l10n.adminNoCategoriesYetMessage,
                ),
              ],
            );
          }

          return ReorderableListView.builder(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 88),
            buildDefaultDragHandles: false,
            itemCount: list.length,
            onReorder: (oldIndex, newIndex) {
              if (newIndex > oldIndex) newIndex -= 1;
              final reordered = List<CategoryEntity>.from(list);
              final moved = reordered.removeAt(oldIndex);
              reordered.insert(newIndex, moved);
              ref
                  .read(adminCategoryControllerProvider.notifier)
                  .reorder(reordered);
            },
            itemBuilder: (context, index) {
              final category = list[index];
              return AdminCategoryTile(
                key: ValueKey(category.id),
                category: category,
                dragHandleIndex: index,
                onEdit: () =>
                    context.push(RouteNames.adminEditCategoryPath(category.id)),
                onDelete: () => _confirmDelete(context, ref, category),
              );
            },
          );
        },
      ),
    );
  }
}
