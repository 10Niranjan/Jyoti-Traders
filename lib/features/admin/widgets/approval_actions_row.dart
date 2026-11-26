import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../l10n/app_localizations.dart';
import '../controllers/approval_controller.dart';

/// Approve/Reject buttons (with the in-flight spinner + result snackbar)
/// for a pending retailer — shared by [RetailerApprovalCard] and
/// [RetailerDetailScreen] so the action logic lives in exactly one place.
class ApprovalActionsRow extends ConsumerWidget {
  final UserEntity user;
  final VoidCallback? onActionComplete;

  const ApprovalActionsRow({
    super.key,
    required this.user,
    this.onActionComplete,
  });

  Future<void> _handle(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function(String) action,
    String successMessage,
  ) async {
    ref.read(approvalInFlightUidProvider.notifier).state = user.uid;
    await action(user.uid);
    ref.read(approvalInFlightUidProvider.notifier).state = null;

    if (!context.mounted) return;
    final result = ref.read(approvalControllerProvider);
    if (result.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.adminActionFailed('${result.error}'),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(successMessage),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
    onActionComplete?.call();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(approvalControllerProvider.notifier);
    final isBusy = ref.watch(approvalInFlightUidProvider) == user.uid;
    final l10n = AppLocalizations.of(context)!;

    if (isBusy) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return Row(
      children: [
        TextButton(
          onPressed: () => _handle(
            context,
            ref,
            controller.reject,
            l10n.adminRejectedMessage(user.shopName),
          ),
          child: Text(
            l10n.adminReject,
            style: const TextStyle(color: AppColors.error),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _handle(
              context,
              ref,
              controller.approve,
              l10n.adminApprovedMessage(user.shopName),
            ),
            icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
            label: Text(l10n.adminApprove),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
