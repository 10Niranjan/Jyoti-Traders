import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/user_entity.dart';
import '../controllers/approval_controller.dart';

/// A pending retailer's card — shop name, owner, phone, address, and
/// Approve/Reject actions. Used by both the dashboard's queue preview
/// (4.1) and the dedicated [ApprovalQueueScreen] (4.2).
class RetailerApprovalCard extends ConsumerWidget {
  final UserEntity user;
  final int index;
  final VoidCallback? onActionComplete;

  const RetailerApprovalCard({super.key, required this.user, this.index = 0, this.onActionComplete});

  Future<void> _handle(BuildContext context, WidgetRef ref, Future<void> Function(String) action, String successMessage) async {
    ref.read(approvalInFlightUidProvider.notifier).state = user.uid;
    await action(user.uid);
    ref.read(approvalInFlightUidProvider.notifier).state = null;

    if (!context.mounted) return;
    final result = ref.read(approvalControllerProvider);
    if (result.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Action failed: ${result.error}'), backgroundColor: AppColors.error),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(successMessage), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating),
    );
    onActionComplete?.call();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // `.watch` (not `.read`) so this autoDispose provider stays alive for
    // the whole async approve/reject call — a plain `.read` lets Riverpod
    // tear the notifier down mid-await once nothing is watching it.
    final controller = ref.watch(approvalControllerProvider.notifier);
    final isBusy = ref.watch(approvalInFlightUidProvider) == user.uid;
    final address = user.address;
    final addressText = address == null ? 'Address not provided yet' : '${address.street}, ${address.city} - ${address.pincode}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isBusy)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                else ...[
                  TextButton(
                    onPressed: () => _handle(context, ref, controller.reject, '${user.shopName} rejected.'),
                    child: const Text('Reject', style: TextStyle(color: AppColors.error)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => _handle(context, ref, controller.approve, '${user.shopName} approved successfully!'),
                    icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: 0.1, delay: (50 * index).ms, duration: 300.ms);
  }
}
