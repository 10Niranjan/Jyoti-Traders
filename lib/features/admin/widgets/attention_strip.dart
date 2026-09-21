import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/route_names.dart';
import '../../../l10n/app_localizations.dart';
import '../controllers/admin_dashboard_controller.dart';

/// "Needs attention" — the dashboard as a to-do list. One tappable chip per
/// thing waiting on the owner (only the non-zero ones), each opening the place
/// to deal with it; an "all caught up" line when nothing is. Hidden until the
/// data has loaded, so it never claims "all clear" prematurely.
class AttentionStrip extends ConsumerWidget {
  const AttentionStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(attentionSummaryProvider);
    if (summary == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // The queue is a pushed screen; Orders and Catalog are shell tabs, which
    // `push` can't switch to (it stacks on the current branch) — `go` can.
    final chips = <Widget>[
      if (summary.pendingApprovals > 0)
        _AttentionChip(
          icon: Icons.how_to_reg_outlined,
          count: summary.pendingApprovals,
          label: l10n.adminAttentionApprovals,
          color: AppColors.accent,
          onTap: () => context.push(RouteNames.adminApprovalQueue),
        ),
      if (summary.unconfirmedPayments > 0)
        _AttentionChip(
          icon: Icons.payments_outlined,
          count: summary.unconfirmedPayments,
          label: l10n.adminAttentionPayments,
          color: AppColors.primary,
          onTap: () => context.go(RouteNames.adminOrders),
        ),
      if (summary.staleOrders > 0)
        _AttentionChip(
          icon: Icons.hourglass_top_rounded,
          count: summary.staleOrders,
          label: l10n.adminAttentionStaleOrders(
            AppConstants.kUnconfirmedOrderMinutes,
          ),
          color: AppColors.warning,
          onTap: () => context.go(RouteNames.adminOrders),
        ),
      if (summary.lowStockProducts > 0)
        _AttentionChip(
          icon: Icons.inventory_2_outlined,
          count: summary.lowStockProducts,
          label: l10n.adminAttentionLowStock,
          color: AppColors.error,
          onTap: () => context.go(RouteNames.adminCatalog),
        ),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.adminAttentionTitle,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 10),
          if (summary.isClear)
            Row(
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 18,
                  color: AppColors.success,
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.adminAttentionAllClear,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ],
            )
          else
            Wrap(spacing: 8, runSpacing: 8, children: chips),
        ],
      ),
    );
  }
}

class _AttentionChip extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AttentionChip({
    required this.icon,
    required this.count,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              '$count',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: 2),
            Icon(Icons.chevron_right_rounded, size: 16, color: color),
          ],
        ),
      ),
    );
  }
}
