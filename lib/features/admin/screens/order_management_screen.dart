import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../../../domain/entities/order_entity.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../../shared/widgets/order_detail_body.dart';
import '../controllers/admin_order_controller.dart';

class OrderManagementScreen extends ConsumerWidget {
  final String orderId;

  const OrderManagementScreen({super.key, required this.orderId});

  Future<void> _changeStatus(
    BuildContext context,
    WidgetRef ref,
    OrderEntity order,
    OrderStatus? newStatus,
  ) async {
    if (newStatus == null || newStatus == order.orderStatus) return;
    final l10n = AppLocalizations.of(context)!;

    final success = await ref
        .read(adminOrderControllerProvider.notifier)
        .updateStatus(order.id, newStatus);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? l10n.adminStatusUpdated(newStatus.label)
              : l10n.adminUpdateFailed(
                  '${ref.read(adminOrderControllerProvider).error}',
                ),
        ),
        backgroundColor: success ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _markAsPaid(
    BuildContext context,
    WidgetRef ref,
    OrderEntity order,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final success = await ref
        .read(adminOrderControllerProvider.notifier)
        .markAsPaid(order.id);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? l10n.adminPaymentConfirmed
              : l10n.adminUpdateFailed(
                  '${ref.read(adminOrderControllerProvider).error}',
                ),
        ),
        backgroundColor: success ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(adminOrderByIdProvider(orderId));
    final isSaving = ref.watch(adminOrderControllerProvider).isLoading;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.adminManageOrderTitle,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
      ),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            ErrorStateWidget(message: l10n.adminCouldntLoadOrder('$e')),
        data: (order) {
          if (order == null) {
            return ErrorStateWidget(message: l10n.adminOrderNotFound);
          }
          return OrderDetailBody(
            order: order,
            showShopName: true,
            header: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonFormField<OrderStatus>(
                initialValue: order.orderStatus,
                decoration: InputDecoration(
                  labelText: l10n.adminOrderStatusLabel,
                  border: InputBorder.none,
                ),
                items: [
                  for (final status in OrderStatus.values)
                    DropdownMenuItem(value: status, child: Text(status.label)),
                ],
                onChanged: isSaving
                    ? null
                    : (v) => _changeStatus(context, ref, order, v),
              ),
            ),
            paymentExtra: order.paymentStatus == PaymentStatus.paid
                ? null
                : SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: isSaving
                          ? null
                          : () => _markAsPaid(context, ref, order),
                      icon: const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 18,
                      ),
                      label: Text(l10n.adminMarkAsPaid),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.success,
                        side: const BorderSide(color: AppColors.success),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
