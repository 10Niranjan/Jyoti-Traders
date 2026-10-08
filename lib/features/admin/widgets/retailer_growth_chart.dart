import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/theme_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../controllers/admin_dashboard_controller.dart';

/// Cumulative approved-retailer count over the last 6 months, sourced from
/// [retailerGrowthProvider].
class RetailerGrowthChart extends ConsumerWidget {
  const RetailerGrowthChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final growthAsync = ref.watch(retailerGrowthProvider);
    final l10n = AppLocalizations.of(context)!;
    final monthFormat = DateFormat.MMM(l10n.localeName);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 20, 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.adminChartRetailerGrowth,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: growthAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(
                child: Text(
                  l10n.adminChartLoadError,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.error,
                  ),
                ),
              ),
              data: (months) {
                if (months.every((m) => m.cumulativeCount == 0)) {
                  return Center(
                    child: Text(
                      l10n.adminChartNoRetailersYet,
                      style: GoogleFonts.inter(fontSize: 12, color: textColor),
                    ),
                  );
                }
                final maxCount = months
                    .map((m) => m.cumulativeCount)
                    .reduce((a, b) => a > b ? a : b);
                final maxY = (maxCount < 4 ? 4 : maxCount + (maxCount ~/ 4) + 1)
                    .toDouble();

                return LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: maxY,
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (_) => AppColors.primary,
                        getTooltipItems: (spots) => spots
                            .map(
                              (s) => LineTooltipItem(
                                l10n.adminChartRetailersTooltip(s.y.round()),
                                const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx < 0 || idx >= months.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                monthFormat.format(months[idx].month),
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: textColor,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          for (var i = 0; i < months.length; i++)
                            FlSpot(
                              i.toDouble(),
                              months[i].cumulativeCount.toDouble(),
                            ),
                        ],
                        isCurved: true,
                        color: AppColors.primary,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.primary.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1);
  }
}
