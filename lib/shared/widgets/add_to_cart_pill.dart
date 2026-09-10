import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

/// Idle "add to cart" control — an outlined pill reading `ADD`, not a bare
/// `+` icon. Two contexts, two looks (matching the Polished reference
/// design): [filled] false is a plain outline for the 2-col product grid,
/// [filled] true is a light-violet fill for horizontal rows (Buy Again,
/// Today's Picks, Search) — never a soft Material shadow either way.
class AddToCartPill extends StatelessWidget {
  final VoidCallback onTap;
  final bool filled;

  const AddToCartPill({super.key, required this.onTap, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(filled ? 8 : 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: filled
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(filled ? 8 : 12),
          border: Border.all(
            color: filled
                ? AppColors.primary.withOpacity(0.3)
                : AppColors.primary,
          ),
        ),
        child: Text(
          'ADD',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

class OutOfStockPill extends StatelessWidget {
  final bool isDark;

  const OutOfStockPill({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final muted = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: muted.withOpacity(0.4)),
      ),
      child: Text(
        'ADD',
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: muted.withOpacity(0.6),
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
