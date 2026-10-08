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

/// Bar chart of orders placed per day over the last 7 days, sourced from
/// [last7DaysOrderCountsProvider].
class OrdersBarChart extends ConsumerWidget {
  const OrdersBarChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final buckets = ref.watch(last7DaysOrderCountsProvider);
    final l10n = AppLocalizations.of(context)!;
    final weekdayFormat = DateFormat.E(l10n.localeName);

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
            l10n.adminChartOrdersLast7Days,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: buckets.when(
              data: (days) {
                if (days.every((d) => d.count == 0)) {
                  return Center(
                    child: Text(
                      l10n.adminChartNoOrdersThisWeek,
                      style: GoogleFonts.inter(fontSize: 12, color: textColor),
                    ),
                  );
                }
                final maxCount = days
                    .map((d) => d.count)
                    .reduce((a, b) => a > b ? a : b);
                final maxY = (maxCount < 4 ? 4 : maxCount + (maxCount ~/ 4) + 1)
                    .toDouble();

                return BarChart(
                  BarChartData(
                    maxY: maxY,
                    alignment: BarChartAlignment.spaceAround,
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => AppColors.primary,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                            BarTooltipItem(
                              l10n.adminChartOrdersTooltip(rod.toY.round()),
                              const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
                            if (idx < 0 || idx >= days.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                weekdayFormat.format(days[idx].day),
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
                    barGroups: [
                      for (var i = 0; i < days.length; i++)
                        BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: days[i].count.toDouble(),
                              // Today's bar (the last one) stands out at full
                              // brand color; the rest use a lighter tint, so
                              // the chart reads "here's today" at a glance.
                              color: i == days.length - 1
                                  ? AppColors.primary
                                  : AppColors.primaryLight,
                              width: 18,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              },
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
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.1);
  }
}
