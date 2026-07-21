import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/category_entity.dart';

class CategoryCard extends StatelessWidget {
  final CategoryEntity category;
  final VoidCallback onTap;

  const CategoryCard({super.key, required this.category, required this.onTap});

  /// No category icon assets exist yet — resolve a reasonable Material icon
  /// from the category name so the grid isn't just blank boxes.
  static IconData _iconFor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('atta') || lower.contains('rice') || lower.contains('grain')) {
      return Icons.agriculture_outlined;
    }
    if (lower.contains('oil') || lower.contains('ghee')) return Icons.opacity_outlined;
    if (lower.contains('spice') || lower.contains('masala')) return Icons.outdoor_grill_outlined;
    if (lower.contains('pulse') || lower.contains('lentil')) return Icons.grain_outlined;
    if (lower.contains('snack') || lower.contains('biscuit')) return Icons.cookie_outlined;
    if (lower.contains('soap') || lower.contains('clean')) return Icons.soap_outlined;
    if (lower.contains('beverage') || lower.contains('drink')) return Icons.local_cafe_outlined;
    if (lower.contains('staple') || lower.contains('sugar') || lower.contains('tea')) {
      return Icons.shopping_basket_outlined;
    }
    return Icons.category_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Icon(_iconFor(category.name), color: AppColors.primary, size: 26),
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
