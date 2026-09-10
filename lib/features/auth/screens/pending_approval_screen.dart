import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/auth_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/route_names.dart';
import '../../../l10n/app_localizations.dart';

class PendingApprovalScreen extends ConsumerWidget {
  const PendingApprovalScreen({super.key});

  // Call Phone helper
  Future<void> _makeCall(BuildContext context) async {
    final Uri url = Uri(scheme: 'tel', path: '9860460325');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, AppLocalizations.of(context)!.pendingUnableToDialPhone);
      }
    }
  }

  // Email helper
  Future<void> _sendEmail(BuildContext context) async {
    final Uri url = Uri(
      scheme: 'mailto',
      path: 'vishvatejkatkar007@gmail.com',
      queryParameters: {
        'subject': 'Jyoti Traders Account Verification Request',
      },
    );
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(
          context,
          AppLocalizations.of(context)!.pendingUnableToOpenEmail,
        );
      }
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppColors.backgroundDark, const Color(0xFF070B19)]
                : [
                    const Color(0xFFFFF7ED),
                    AppColors.backgroundLight,
                  ], // soft amber to white
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),

                // Pending Verification Icon / Animation
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                          )
                          .animate(
                            onPlay: (controller) {
                              if (!kIsWeb &&
                                  Platform.environment.containsKey(
                                    'FLUTTER_TEST',
                                  )) {
                                return;
                              }
                              controller.repeat(reverse: true);
                            },
                          )
                          .scale(
                            begin: const Offset(0.9, 0.9),
                            end: const Offset(1.1, 1.1),
                            duration: 1500.ms,
                            curve: Curves.easeInOut,
                          ),

                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                      ),

                      const Icon(
                        Icons.pending_actions_rounded,
                        size: 56,
                        color: AppColors.warning,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Main message
                Text(
                  l10n.pendingTitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),

                const SizedBox(height: 12),

                Text(
                  l10n.pendingMessage,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.5,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                const SizedBox(height: 32),

                // Refresh Status Button
                ElevatedButton.icon(
                  onPressed: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.pendingCheckingStatus),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                    await ref
                        .read(authControllerProvider.notifier)
                        .checkApprovalStatus();
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(l10n.pendingCheckStatusAgain),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 1,
                  ),
                ).animate().fadeIn(delay: 350.ms),

                const SizedBox(height: 12),

                // Read-only catalog preview while waiting for approval.
                OutlinedButton.icon(
                  onPressed: () => context.go(RouteNames.home),
                  icon: const Icon(Icons.storefront_outlined),
                  label: Text(l10n.pendingBrowseCatalog),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms),

                const Spacer(),

                // Contact Support Panel
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.black12,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.pendingContactSupportTitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Call Button
                      OutlinedButton.icon(
                        onPressed: () => _makeCall(context),
                        icon: const Icon(
                          Icons.phone_rounded,
                          color: AppColors.success,
                        ),
                        label: Text(
                          l10n.pendingCallOwner,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.success),
                          foregroundColor: AppColors.success,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Email Button
                      OutlinedButton.icon(
                        onPressed: () => _sendEmail(context),
                        icon: const Icon(
                          Icons.email_outlined,
                          color: AppColors.primary,
                        ),
                        label: Text(
                          l10n.pendingEmailSupport,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),

                const SizedBox(height: 24),

                // Log out / Exit Button
                TextButton.icon(
                  onPressed: () =>
                      ref.read(authControllerProvider.notifier).signOut(),
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.error,
                  ),
                  label: Text(
                    l10n.pendingSignOut,
                    style: GoogleFonts.inter(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
