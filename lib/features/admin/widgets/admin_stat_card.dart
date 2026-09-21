import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/trend_label.dart';

/// A single dashboard stat tile fed by an [AsyncValue<int>] stream — shows
/// a shimmer placeholder while loading and a dash on error, matching the
/// loading/empty/error convention used across the rest of the app.
class AdminStatCard extends StatelessWidget {
  final String title;
  final AsyncValue<int> value;
  final IconData icon;
  final Color color;
  final String Function(int)? formatter;

  /// Percent change against the same window last week (null = no baseline,
  /// show nothing). Positive is up.
  final double? trend;

  const AdminStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.formatter,
    this.trend,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          value.when(
            // TweenAnimationBuilder retargets from whatever's on screen to
            // the new `end` on every rebuild, so this both counts up from 0
            // on first load and animates smoothly on later live updates —
            // no manual "previous value" tracking needed.
            data: (v) => TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: v),
              duration:
                  (MediaQuery.maybeOf(context)?.disableAnimations ?? false)
                  ? Duration.zero
                  : const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, animatedValue, _) => Text(
                formatter?.call(animatedValue) ?? '$animatedValue',
                style: GoogleFonts.inter(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ),
            loading: () => Shimmer.fromColors(
              baseColor: isDark ? AppColors.surfaceDark : Colors.grey.shade300,
              highlightColor: isDark
                  ? AppColors.backgroundDark
                  : Colors.grey.shade100,
              child: Container(
                width: 40,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            error: (_, _) => Text(
              '—',
              style: GoogleFonts.inter(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: AppColors.error,
              ),
            ),
          ),
          if (trend != null) ...[
            const SizedBox(height: 6),
            TrendLabel(
              percent: trend!,
              labelFor: AppLocalizations.of(context)!.adminTrendVsLastWeek,
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }
}
