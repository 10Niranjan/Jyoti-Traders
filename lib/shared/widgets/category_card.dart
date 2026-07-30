import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/category_entity.dart';

class CategoryCard extends StatelessWidget {
  final CategoryEntity category;
  final VoidCallback onTap;

  const CategoryCard({super.key, required this.category, required this.onTap});

  /// Fallback when no admin-uploaded icon exists — resolves a reasonable
  /// Material icon from the category name so the grid isn't blank boxes.
  static IconData _iconFor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('ayurved') || lower.contains('medicine')) return Icons.local_pharmacy_outlined;
    if (lower.contains('electrical')) return Icons.electrical_services_outlined;
    if (lower.contains('shampoo')) return Icons.shower_outlined;
    if (lower.contains('tea')) return Icons.emoji_food_beverage_outlined;
    if (lower.contains('atta') || lower.contains('rice') || lower.contains('grain')) {
      return Icons.agriculture_outlined;
    }
    if (lower.contains('oil') || lower.contains('ghee')) return Icons.opacity_outlined;
    if (lower.contains('spice') || lower.contains('masala')) return Icons.outdoor_grill_outlined;
    if (lower.contains('pulse') || lower.contains('lentil')) return Icons.grain_outlined;
    if (lower.contains('snack') || lower.contains('biscuit')) return Icons.cookie_outlined;
    if (lower.contains('soap') || lower.contains('cosmetic') || lower.contains('clean')) {
      return Icons.soap_outlined;
    }
    if (lower.contains('beverage') || lower.contains('drink')) return Icons.local_cafe_outlined;
    if (lower.contains('paan')) return Icons.eco_outlined;
    if (lower.contains('firecracker')) return Icons.celebration_outlined;
    if (lower.contains('hardware')) return Icons.hardware_outlined;
    if (lower.contains('grocery') || lower.contains('staple') || lower.contains('sugar')) {
      return Icons.shopping_basket_outlined;
    }
    return Icons.category_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ringColor = AppColors.categoryPalette[category.displayOrder % AppColors.categoryPalette.length];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: ringColor.withOpacity(isDark ? 0.2 : 0.1),
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child: category.iconUrl.isEmpty
                ? Icon(_iconFor(category.name), color: ringColor, size: 26)
                : _CategoryIconImage(iconUrl: category.iconUrl, fallbackColor: ringColor, fallbackIcon: _iconFor(category.name)),
          ),
          const SizedBox(height: 8),
          Text(
            category.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

/// Renders an admin-uploaded category icon — a real Storage URL, or, in
/// simulation mode where no bucket exists, a local file path. Mirrors the
/// exact same local-path-vs-URL check `AdminCategoryTile._Thumbnail` uses.
class _CategoryIconImage extends StatelessWidget {
  final String iconUrl;
  final Color fallbackColor;
  final IconData fallbackIcon;

  const _CategoryIconImage({required this.iconUrl, required this.fallbackColor, required this.fallbackIcon});

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(fallbackIcon, color: fallbackColor, size: 26);

    if (!iconUrl.startsWith('http')) {
      return Image.file(
        File(iconUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Center(child: fallback),
      );
    }

    return CachedNetworkImage(
      imageUrl: iconUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Center(child: fallback),
      errorWidget: (context, url, error) => Center(child: fallback),
    );
  }
}
