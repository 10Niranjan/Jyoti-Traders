import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

/// Idle "add to cart" control — an outlined pill reading `ADD`, not a bare
/// `+` icon. Styling (white fill, colored 1px border, and a hard-edged,
/// same-color offset shadow with zero blur — a "sticker" outline rather than
/// a soft Material shadow) matches Zepto's own grid-card add button,
/// confirmed by inspecting its computed styles directly on zeptonow.com.
///
/// Shared by `ProductCard` and search's result tile so the two grids the app
/// actually has can't drift into two different "add" looks.
class AddToCartPill extends StatelessWidget {
  final VoidCallback onTap;

  const AddToCartPill({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary, width: 1),
          boxShadow: [
            BoxShadow(color: AppColors.primary, offset: const Offset(1.5, 1.5)),
          ],
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
    final muted = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
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
