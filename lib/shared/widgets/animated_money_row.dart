import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_colors.dart';
import '../../core/utils/currency_formatter.dart';

/// A [SummaryRow]-shaped label/value line whose value counts up or down to
/// [amount] instead of snapping — for a grand total that moves as a coupon
/// or delivery charge resolves. `begin == end` on the very first build (no
/// prior value to animate from), so it only animates on later changes, not
/// on the screen's initial render.
///
/// `TweenAnimationBuilder` retargets from whatever's currently on screen to
/// the new `end` whenever [amount] changes on a rebuild — no manual
/// "previous value" tracking needed (same idiom `AdminStatCard` already uses
/// for its dashboard counters).
class AnimatedMoneyRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool bold;
  final Color? valueColor;

  const AnimatedMoneyRow({
    super.key,
    required this.label,
    required this.amount,
    this.bold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.inter(
      fontSize: bold ? 15 : 13,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    );
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    // Same colour rules as `SummaryRow` — the two sit in one totals block.
    final labelColor = bold ? context.textPrimary : context.textSecondary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style.copyWith(color: labelColor)),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: amount, end: amount),
            duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 320),
            curve: Curves.easeOut,
            builder: (context, value, child) => Text(
              formatRupees(value),
              style: style.copyWith(color: valueColor ?? context.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
