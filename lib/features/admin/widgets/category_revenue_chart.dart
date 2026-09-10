import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/admin_dashboard_controller.dart';

/// Donut chart of revenue by category, sourced from [categoryRevenueProvider].
/// Everything past the top 5 categories is folded into one "Other" slice so
/// a long tail of small categories doesn't turn the legend into a wall of text.
class CategoryRevenueChart extends ConsumerWidget {
  const CategoryRevenueChart({super.key});

  static const _maxSlices = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final revenueAsync = ref.watch(categoryRevenueProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Revenue by Category',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          revenueAsync.when(
            loading: () => const SizedBox(
              height: 160,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => SizedBox(
              height: 160,
              child: Center(
                child: Text(
                  "Couldn't load chart data",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.error,
                  ),
                ),
              ),
            ),
            data: (categories) {
              if (categories.isEmpty) {
                return SizedBox(
                  height: 160,
                  child: Center(
                    child: Text(
                      'No sales yet',
                      style: GoogleFonts.inter(fontSize: 12, color: textColor),
                    ),
                  ),
                );
              }

              final top = categories.take(_maxSlices).toList();
              final otherRevenue = categories
                  .skip(_maxSlices)
                  .fold(0.0, (sum, c) => sum + c.revenue);
              final slices = [
                ...top,
                if (otherRevenue > 0)
                  CategoryRevenue('other', 'Other', otherRevenue),
              ];
              final total = slices.fold(0.0, (sum, c) => sum + c.revenue);

              return Row(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 32,
                        sections: [
                          for (var i = 0; i < slices.length; i++)
                            PieChartSectionData(
                              value: slices[i].revenue,
                              color:
                                  AppColors.categoryPalette[i %
                                      AppColors.categoryPalette.length],
                              showTitle: false,
                              radius: 24,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < slices.length; i++)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.categoryPalette[i %
                                            AppColors.categoryPalette.length],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    slices[i].categoryName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${(slices[i].revenue / total * 100).round()}%',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 150.ms).slideY(begin: 0.1);
  }
}
