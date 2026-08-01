import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/route_names.dart';
import '../../../domain/entities/user_entity.dart';
import 'approval_actions_row.dart';

/// A pending retailer's card — shop name, owner, phone, address, and
/// Approve/Reject actions. Used by both the dashboard's queue preview
/// (4.1) and the dedicated [ApprovalQueueScreen] (4.2). Tapping the card
/// (outside the action buttons) opens [RetailerDetailScreen] with the
/// retailer's full profile.
class RetailerApprovalCard extends ConsumerWidget {
  final UserEntity user;
  final int index;
  final VoidCallback? onActionComplete;

  const RetailerApprovalCard({super.key, required this.user, this.index = 0, this.onActionComplete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final address = user.address;
    final addressText = address == null ? 'Address not provided yet' : '${address.street}, ${address.city} - ${address.pincode}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push(RouteNames.adminRetailerDetailPath(user.uid), extra: user),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      user.shopName.isNotEmpty ? user.shopName[0].toUpperCase() : 'U',
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.shopName, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text('Owner: ${user.fullName}', style: GoogleFonts.inter(fontSize: 12)),
                        const SizedBox(height: 2),
                        Text(
                          'Phone: ${user.phone}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          addressText,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontStyle: address == null ? FontStyle.italic : FontStyle.normal,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                ],
              ),
              const Divider(height: 24),
              ApprovalActionsRow(user: user, onActionComplete: onActionComplete),
            ],
          ),
        ),
      ),
    ).animate().slideY(begin: 0.1, delay: (50 * index).ms, duration: 300.ms);
  }
}
