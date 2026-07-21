import 'dart:io' show Platform;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

/// No promotional photography exists for this app yet, so the Home banner
/// is a small carousel of informational slides instead of real images.
class PromoBannerCarousel extends StatelessWidget {
  const PromoBannerCarousel({super.key});

  static final List<(IconData, String, String)> _slides = [
    (
      Icons.info_outline_rounded,
      'Wholesale Purchase Order Enforced',
      'Minimum order value: ${AppConstants.kMinOrderAmount.toStringAsFixed(0)} at checkout.',
    ),
    (
      Icons.local_shipping_outlined,
      'Own Fleet Delivery',
      'Delivered by our own delivery staff — no third-party logistics.',
    ),
    (
      Icons.support_agent_rounded,
      'Need Help?',
      'Call ${AppConstants.kSupportPhone} for support with your order.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 92,
        viewportFraction: 1,
        // A repeating autoPlay Timer never settles under widget tests
        // (pumpAndSettle would hang forever) — same guard as the splash
        // icon animation in app_router.dart.
        autoPlay: kIsWeb || !Platform.environment.containsKey('FLUTTER_TEST'),
        autoPlayInterval: const Duration(seconds: 5),
      ),
      items: _slides.map((slide) {
        final (icon, title, body) = slide;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              CircleAvatar(backgroundColor: Colors.white24, child: Icon(icon, color: Colors.white)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      body,
                      style: GoogleFonts.inter(color: Colors.white.withOpacity(0.9), fontSize: 11, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
