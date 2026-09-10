import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../controllers/admin_dashboard_controller.dart';

/// Horizontal bars showing how many active orders have *reached* each
/// stage (pending → confirmed → out for delivery → delivered), sourced from
/// [orderStatusFunnelProvider]. Each bar is scaled against the first
/// stage's count, so the shrinking width reads as a drop-off funnel.
class OrderStatusFunnel extends ConsumerWidget {
  const OrderStatusFunnel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final funnelAsync = ref.watch(orderStatusFunnelProvider);

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
            'Order Status Funnel',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          funnelAsync.when(
            loading: () => const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => SizedBox(
              height: 120,
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
            data: (stages) {
              if (stages.isEmpty || stages.first.count == 0) {
                return SizedBox(
                  height: 120,
                  child: Center(
                    child: Text(
                      'No active orders yet',
                      style: GoogleFonts.inter(fontSize: 12, color: textColor),
                    ),
                  ),
                );
              }
              final maxCount = stages.first.count;

              return Column(
                children: [
                  for (final stage in stages)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 90,
                            child: Text(
                              stage.status.label,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: textColor,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: maxCount == 0
                                    ? 0
                                    : stage.count / maxCount,
                                minHeight: 18,
                                backgroundColor: isDark
                                    ? Colors.white10
                                    : Colors.black12,
                                valueColor: const AlwaysStoppedAnimation(
                                  AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 24,
                            child: Text(
                              '${stage.count}',
                              textAlign: TextAlign.right,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
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
    ).animate().fadeIn(duration: 400.ms, delay: 250.ms).slideY(begin: 0.1);
  }
}
