import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

/// Shown on both the dashboard preview and the full [ApprovalQueueScreen]
/// when there are no retailers awaiting approval.
class EmptyApprovalQueueCard extends ConsumerWidget {
  const EmptyApprovalQueueCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        children: [
          const Icon(Icons.verified_user_outlined, size: 48, color: AppColors.success),
          const SizedBox(height: 16),
          Text('Approval queue is clear!', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 4),
          Text(
            'All registered retailers are verified.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }
}
