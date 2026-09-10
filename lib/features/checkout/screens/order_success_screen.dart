import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/route_names.dart';
import '../../../core/utils/extensions.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../l10n/app_localizations.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String orderId;

  const OrderSuccessScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.success.withOpacity(0.12), shape: BoxShape.circle),
                child: const Icon(Icons.check_circle_rounded, size: 72, color: AppColors.success),
              ).animate().scale(duration: 450.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 24),
              Text(
                l10n.orderSuccessTitle,
                style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold),
              ).animate().fadeIn(delay: 150.ms),
              const SizedBox(height: 8),
              Text(
                l10n.orderSuccessOrderNumber(orderId.shortId),
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 4),
              Text(
                l10n.orderSuccessMessage,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondaryLight),
              ).animate().fadeIn(delay: 250.ms),
              const SizedBox(height: 32),
              PrimaryButton(
                label: l10n.orderSuccessViewOrder,
                onPressed: () => context.pushReplacement(RouteNames.orderDetailPath(orderId)),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go(RouteNames.home),
                child: Text(l10n.orderSuccessContinueShopping),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
