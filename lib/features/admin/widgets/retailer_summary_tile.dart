import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/route_names.dart';
import '../../../l10n/app_localizations.dart';
import '../controllers/admin_retailer_controller.dart';

/// A single retailer row — shop name, owner, lifetime spend and order
/// count. Tapping opens their full order history via [RouteNames.adminRetailerOrdersPath].
class RetailerSummaryTile extends StatelessWidget {
  final RetailerSummary summary;

  const RetailerSummaryTile({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final user = summary.user;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push(RouteNames.adminRetailerOrdersPath(user.uid)),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  user.shopName.isNotEmpty
                      ? user.shopName[0].toUpperCase()
                      : 'R',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.shopName,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.adminOwnerNameValue(user.fullName),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    summary.totalSpend.formatted,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.adminOrderCount(summary.orderCount),
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondaryLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
