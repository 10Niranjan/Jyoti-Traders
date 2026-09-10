import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/value_objects/money.dart';
import '../../l10n/app_localizations.dart';
import 'first_run_hint.dart';

const _kFloatingCartBarHintId = 'floating_cart_bar';

/// Persistent "N items · ₹total · View Cart" pill, docked above the bottom
/// nav bar on Home/Search/Category screens (PRD/mockup: quick-commerce apps
/// keep the cart one tap away without forcing a tab switch to check it).
/// Slides/fades out entirely when the cart is empty.
///
/// Deliberately doesn't add a [FirstRunHint] text bubble above itself the
/// way the Buy Again rail does — both call sites (`_RetailerShell`'s
/// `Positioned`, `CategoryProductsScreen`'s `bottomNavigationBar`) reserve a
/// fixed height for exactly this bar's own content (see
/// `_kFloatingCartBarReservedHeight` — a taller bubble would silently
/// reintroduce the overlap bug that constant was added to fix). A one-time
/// pulse on the "View Cart" pill itself draws the same attention without
/// changing this widget's height.
class FloatingCartBar extends ConsumerWidget {
  final CartEntity cart;
  final VoidCallback onTap;

  const FloatingCartBar({super.key, required this.cart, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final hintSeen = ref
        .watch(firstRunHintsProvider)
        .contains(_kFloatingCartBarHintId);
    final minimum = Money(AppConstants.kMinOrderAmount);
    final belowMinimum = cart.subtotal < minimum;
    // Browsing-time nudge toward the same ₹2,500 gate Cart/Checkout already
    // enforce — clamped so the bar never overshoots 100% on the (impossible
    // but not worth crashing over) subtotal > minimum edge.
    final progress = (cart.subtotal.amount / minimum.amount).clamp(0.0, 1.0);
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
              onTap: () {
                if (!hintSeen) {
                  ref
                      .read(firstRunHintsProvider.notifier)
                      .dismiss(_kFloatingCartBarHintId);
                }
                onTap();
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  // Deliberately a fixed dark pill in both themes (this app's
                  // white/light text on it is hardcoded, not theme-aware) —
                  // exact `slate-900` match to the Polished reference, not
                  // `textPrimaryLight`, which is the exact same hex as
                  // `backgroundDark` and so was invisible against a
                  // dark-mode screen.
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (belowMinimum) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 3,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation(
                            AppColors.warning,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              belowMinimum
                                  ? l10n.cartAddMoreShort(
                                      (minimum - cart.subtotal).formatted,
                                    )
                                  : l10n.cartItemCount(cart.itemCount),
                              style: GoogleFonts.inter(
                                fontSize: 10.5,
                                color: belowMinimum
                                    ? AppColors.warning
                                    : Colors.white70,
                                fontWeight: belowMinimum
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                letterSpacing: 0.3,
                              ),
                            ),
                            Text(
                              cart.subtotal.formatted,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        // A filled pill, not link-style text — reads as a tappable
                        // button in its own right rather than a caption next to
                        // the price, matching how Zepto's own cart/checkout CTAs
                        // are always a solid, self-contained button.
                        _buildViewCartPill(l10n, cart.itemCount, hintSeen),
                      ],
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

  Widget _buildViewCartPill(
    AppLocalizations l10n,
    int itemCount,
    bool hintSeen,
  ) {
    final pill = Container(
      key: ValueKey(itemCount),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.cartViewCart,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.arrow_forward_rounded,
            size: 15,
            color: Colors.white,
          ),
        ],
      ),
    );
    final entrance = pill.animate().scale(
      begin: const Offset(0.9, 0.9),
      end: const Offset(1, 1),
      duration: 180.ms,
      curve: Curves.easeOutBack,
    );
    if (hintSeen) return entrance;
    // First-time nudge: one extra pulse so a new retailer notices the pill
    // is tappable, without a repeating animation that would hang widget
    // tests the way `PromoBannerCarousel`'s old `autoPlay` timer once did —
    // it plays once because [hintSeen] flipping true (on tap) rebuilds this
    // widget without this branch, rather than the animation looping itself.
    return entrance
        .then(delay: 400.ms)
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.12, 1.12),
          duration: 220.ms,
          curve: Curves.easeOut,
        )
        .then()
        .scale(
          begin: const Offset(1.12, 1.12),
          end: const Offset(1, 1),
          duration: 220.ms,
          curve: Curves.easeIn,
        );
  }
}
