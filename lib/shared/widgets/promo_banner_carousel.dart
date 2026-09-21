import 'dart:io' show Platform;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../domain/entities/promo_banner_entity.dart';
import '../../features/admin/controllers/admin_banner_controller.dart';
import '../../l10n/app_localizations.dart';

/// No promotional photography exists for this app yet, so the Home banner
/// is a carousel of text slides instead of real images: the admin's own
/// offers first (newest leading), then the fixed informational slides.
class PromoBannerCarousel extends ConsumerWidget {
  const PromoBannerCarousel({super.key});

  List<(IconData, String, String)> _slides(
    AppLocalizations l10n,
    List<PromoBannerEntity> offers,
  ) => [
        for (final offer in offers) (Icons.campaign_rounded, offer.title, offer.body),
        (
          Icons.info_outline_rounded,
          l10n.promoMinOrderTitle,
          l10n.promoMinOrderBody(formatRupees(AppConstants.kMinOrderAmount)),
        ),
        (
          Icons.local_shipping_outlined,
          l10n.promoDeliveryTitle,
          l10n.promoDeliveryBody,
        ),
        (
          Icons.support_agent_rounded,
          l10n.promoHelpTitle,
          l10n.promoHelpBody(AppConstants.kSupportPhone),
        ),
      ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final offers = ref.watch(activePromoBannersProvider);
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
      items: _slides(l10n, offers).map((slide) {
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    if (body.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(color: Colors.white.withOpacity(0.9), fontSize: 11, height: 1.4),
                      ),
                    ],
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
