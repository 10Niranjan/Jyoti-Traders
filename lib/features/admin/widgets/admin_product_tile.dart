import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/status_pill.dart';

/// One row in the admin product list — thumbnail, name, price/unit, stock
/// (highlighted when low), an inactive badge, and edit/delete actions.
class AdminProductTile extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AdminProductTile({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLowStock = product.stock <= AppConstants.kLowStockThreshold;
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 56,
                height: 56,
                child: _Thumbnail(imageUrl: product.imageUrl, isDark: isDark),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                      if (!product.isActive)
                        StatusPill(
                          label: l10n.adminInactiveBadge,
                          color: AppColors.textSecondaryLight,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.isWeighed
                        ? l10n.homeFromRatePerKg(
                            product.rateSlabs!.bestRatePerKg.toStringAsFixed(0),
                          )
                        : l10n.adminPricePerUnit(
                            product.price.formatted,
                            product.unit.value,
                          ),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (isLowStock) ...[
                        const Icon(
                          Icons.warning_amber_rounded,
                          size: 14,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        l10n.adminStockLabel(product.stock),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: isLowStock
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isLowStock
                              ? AppColors.error
                              : (isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
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
          ],
        ),
      ),
    );
  }
}

/// Renders either a remote URL or — in simulation mode, where there's no
/// Storage bucket — a local file path saved by `ImageUploadService`.
class _Thumbnail extends StatelessWidget {
  final String imageUrl;
  final bool isDark;

  const _Thumbnail({required this.imageUrl, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final placeholderColor = isDark ? Colors.white12 : Colors.black12;
    final fallback = Container(
      color: placeholderColor,
      child: const Icon(Icons.image_outlined, size: 22),
    );

    if (imageUrl.isEmpty) return fallback;

    if (!imageUrl.startsWith('http')) {
      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallback,
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(color: placeholderColor),
      errorWidget: (context, url, error) => fallback,
    );
  }
}
