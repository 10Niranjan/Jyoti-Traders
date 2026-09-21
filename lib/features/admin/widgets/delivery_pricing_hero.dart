import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../l10n/app_localizations.dart';

/// The top of Delivery Settings: what the admin is actually setting, as one
/// big live number. [rate] follows the field below it, so typing, tapping a
/// quick rate or stepping all animate the same readout. A truck drives from
/// the warehouse to the shop once when the card appears.
class DeliveryPricingHero extends StatelessWidget {
  /// `null` while the field doesn't hold a number yet.
  final double? rate;

  const DeliveryPricingHero({super.key, required this.rate});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.30),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -50,
            child: _Glow(size: 180, color: Colors.white.withOpacity(0.14)),
          ),
          Positioned(
            left: -30,
            bottom: -60,
            child: _Glow(
              size: 150,
              color: AppColors.accentLight.withOpacity(0.30),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.18),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.32),
                        ),
                      ),
                      child: const Icon(
                        Icons.local_shipping_rounded,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.profileDeliverySettings,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withOpacity(0.92),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    _RateReadout(rate: rate),
                    const SizedBox(width: 10),
                    Text(
                      l10n.adminDeliveryPerKm,
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.adminDeliveryHeroSubtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    height: 1.35,
                    color: Colors.white.withOpacity(0.82),
                  ),
                ),
                const SizedBox(height: 22),
                const _RouteStrip(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The big number. Retargets from whatever is on screen to the new value
/// (the same `begin == end` idiom as `AnimatedMoneyRow`), so it counts up or
/// down as the rate changes and does nothing on first build.
class _RateReadout extends StatelessWidget {
  final double? rate;

  const _RateReadout({required this.rate});

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.inter(
      fontSize: 50,
      fontWeight: FontWeight.w800,
      height: 1.0,
      color: Colors.white,
    );
    final value = rate;
    if (value == null) return Text('—', style: style);

    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: value, end: value),
      duration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      builder: (context, v, _) => Text(formatRupees(v), style: style),
    );
  }
}

/// warehouse ── ── 🚚 ── ── shop. The truck makes the trip once.
class _RouteStrip extends StatelessWidget {
  const _RouteStrip();

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return Row(
      children: [
        const Icon(Icons.warehouse_rounded, size: 24, color: Colors.white),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 30,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Positioned.fill(
                  child: CustomPaint(painter: _DashedLinePainter()),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: reduceMotion
                      ? Duration.zero
                      : const Duration(milliseconds: 1600),
                  curve: Curves.easeInOutCubic,
                  builder: (context, t, child) =>
                      Align(alignment: Alignment(-1 + 2 * t, 0), child: child),
                  child: const Icon(
                    Icons.local_shipping_rounded,
                    size: 26,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Icon(Icons.storefront_rounded, size: 24, color: Colors.white),
      ],
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.55)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final y = size.height / 2;
    for (double x = 0; x < size.width; x += 11) {
      canvas.drawLine(Offset(x, y), Offset(x + 5, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Glow extends StatelessWidget {
  final double size;
  final Color color;

  const _Glow({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withOpacity(0)]),
      ),
    );
  }
}
