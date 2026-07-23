import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../../../domain/entities/order_entity.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../../shared/widgets/order_detail_body.dart';
import '../controllers/admin_order_controller.dart';

class OrderManagementScreen extends ConsumerWidget {
  final String orderId;

  const OrderManagementScreen({super.key, required this.orderId});

  Future<void> _changeStatus(BuildContext context, WidgetRef ref, OrderEntity order, OrderStatus? newStatus) async {
    if (newStatus == null || newStatus == order.orderStatus) return;

    final success = await ref.read(adminOrderControllerProvider.notifier).updateStatus(order.id, newStatus);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Status updated to ${newStatus.label}.'
              : 'Update failed: ${ref.read(adminOrderControllerProvider).error}',
        ),
        backgroundColor: success ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _markAsPaid(BuildContext context, WidgetRef ref, OrderEntity order) async {
    final success = await ref.read(adminOrderControllerProvider.notifier).markAsPaid(order.id);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Payment confirmed.' : 'Update failed: ${ref.read(adminOrderControllerProvider).error}',
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

    return Scaffold(
      appBar: AppBar(title: Text('Manage Order', style: GoogleFonts.poppins(fontWeight: FontWeight.bold))),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorStateWidget(message: 'Couldn\'t load order: $e'),
        data: (order) {
          if (order == null) {
            return const ErrorStateWidget(message: 'This order could not be found.');
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
                decoration: const InputDecoration(labelText: 'Order status', border: InputBorder.none),
                items: [
                  for (final status in OrderStatus.values)
                    DropdownMenuItem(value: status, child: Text(status.label)),
                ],
                onChanged: isSaving ? null : (v) => _changeStatus(context, ref, order, v),
              ),
            ),
            paymentExtra: order.paymentStatus == PaymentStatus.paid
                ? null
                : OutlinedButton.icon(
                    onPressed: isSaving ? null : () => _markAsPaid(context, ref, order),
                    icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                    label: const Text('Mark as Paid'),
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.success),
                  ),
          );
        },
      ),
    );
  }
}
