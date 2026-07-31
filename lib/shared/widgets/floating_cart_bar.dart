import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/cart_entity.dart';

/// Persistent "N items · ₹total · View Cart" pill, docked above the bottom
/// nav bar on Home/Search/Category screens (PRD/mockup: quick-commerce apps
/// keep the cart one tap away without forcing a tab switch to check it).
/// Slides/fades out entirely when the cart is empty.
class FloatingCartBar extends StatelessWidget {
  final CartEntity cart;
  final VoidCallback onTap;

  const FloatingCartBar({super.key, required this.cart, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: cart.isEmpty,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        offset: cart.isEmpty ? const Offset(0, 0.3) : Offset.zero,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: cart.isEmpty ? 0 : 1,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  // Deliberately a fixed dark pill in both themes (this app's
                  // white/light text on it is hardcoded, not theme-aware) —
                  // `surfaceDark`, not `textPrimaryLight`, which is the exact
                  // same hex as `backgroundDark` and so was invisible against
                  // a dark-mode screen.
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 6)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cart.itemCount == 1 ? '1 item' : '${cart.itemCount} items',
                          style: GoogleFonts.inter(fontSize: 10.5, color: Colors.white70, letterSpacing: 0.3),
                        ),
                        Text(
                          cart.subtotal.formatted,
                          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                    // A filled pill, not link-style text — reads as a tappable
                    // button in its own right rather than a caption next to
                    // the price, matching how Zepto's own cart/checkout CTAs
                    // are always a solid, self-contained button.
                    Container(
                      key: ValueKey(cart.itemCount),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View Cart',
                            style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_rounded, size: 15, color: Colors.white),
                        ],
                      ),
                    ).animate().scale(
                          begin: const Offset(0.9, 0.9),
                          end: const Offset(1, 1),
                          duration: 180.ms,
                          curve: Curves.easeOutBack,
                        ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
