import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/route_names.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import '../controllers/admin_category_controller.dart';
import '../widgets/admin_category_tile.dart';

class ManageCategoriesScreen extends ConsumerWidget {
  const ManageCategoriesScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, CategoryEntity category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Delete category?', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 17)),
        content: Text(
          '"${category.name}" will be permanently removed. Products already assigned to it will keep '
          'their category id but won\'t show up under any visible category. To hide it from retailers '
          'without losing it, edit the category and turn off "Active" instead.',
          style: GoogleFonts.inter(fontSize: 13),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final success = await ref.read(adminCategoryControllerProvider.notifier).delete(category.id);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? '${category.name} deleted.' : 'Delete failed: ${ref.read(adminCategoryControllerProvider).error}'),
        backgroundColor: success ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(adminCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Categories', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.adminAddCategory),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Category'),
      ),
      body: RefreshIndicator(
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
                message: 'Couldn\'t load categories: $e',
                onRetry: () => ref.invalidate(adminCategoriesProvider),
              ),
            ],
          ),
          data: (list) {
            if (list.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(18.0),
                children: const [
                  EmptyStateWidget(
                    icon: Icons.category_outlined,
                    title: 'No categories yet',
                    message: 'Tap "Add Category" to create your first one.',
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
                ref.read(adminCategoryControllerProvider.notifier).reorder(reordered);
              },
              itemBuilder: (context, index) {
                final category = list[index];
                return AdminCategoryTile(
                  key: ValueKey(category.id),
                  category: category,
                  dragHandleIndex: index,
                  onEdit: () => context.push(RouteNames.adminEditCategoryPath(category.id)),
                  onDelete: () => _confirmDelete(context, ref, category),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
