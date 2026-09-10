import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/status_pill.dart';

/// One row in the admin category list — thumbnail, name, an inactive badge,
/// a drag handle for reordering, and edit/delete actions.
class AdminCategoryTile extends StatelessWidget {
  final CategoryEntity category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final int dragHandleIndex;

  const AdminCategoryTile({
    super.key,
    required this.category,
    required this.onEdit,
    required this.onDelete,
    required this.dragHandleIndex,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ReorderableDragStartListener(
              index: dragHandleIndex,
              child: const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.drag_handle_rounded,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 48,
                height: 48,
                child: _Thumbnail(iconUrl: category.iconUrl, isDark: isDark),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      category.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                  if (!category.isActive)
                    StatusPill(
                      label: l10n.adminInactiveBadge,
                      color: AppColors.textSecondaryLight,
                    ),
                ],
              ),
            ),
            IconButton(
              onPressed: onEdit,
              visualDensity: VisualDensity.compact,
              icon: const Icon(
                Icons.edit_outlined,
                size: 20,
                color: AppColors.primary,
              ),
              tooltip: l10n.adminEditTooltip,
            ),
            IconButton(
              onPressed: onDelete,
              visualDensity: VisualDensity.compact,
              icon: const Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: AppColors.error,
              ),
              tooltip: l10n.adminDeleteTooltip,
            ),
          ],
        ),
      ),
    );
  }
}

/// Renders either a remote URL or — in simulation mode, where there's no
/// Storage bucket — a local file path saved by `ImageUploadService`.
class _Thumbnail extends StatelessWidget {
  final String iconUrl;
  final bool isDark;

  const _Thumbnail({required this.iconUrl, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final placeholderColor = isDark ? Colors.white12 : Colors.black12;
    final fallback = Container(
      color: placeholderColor,
      child: const Icon(Icons.category_outlined, size: 20),
    );

    if (iconUrl.isEmpty) return fallback;

    if (!iconUrl.startsWith('http')) {
      return Image.file(
        File(iconUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallback,
      );
    }

    return CachedNetworkImage(
      imageUrl: iconUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(color: placeholderColor),
      errorWidget: (context, url, error) => fallback,
    );
  }
}
