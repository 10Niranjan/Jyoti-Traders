import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/route_names.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/extensions.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../../shared/widgets/order_status_badge.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import '../controllers/order_controller.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(orderHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ordersAsync.when(
          loading: () => const ListShimmerLoader(itemHeight: 88),
          error: (error, stack) => ErrorStateWidget(onRetry: () => ref.invalidate(orderHistoryProvider)),
          data: (orders) {
            if (orders.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.receipt_long_outlined,
                title: 'No orders yet',
                message: 'Your placed orders will show up here.',
              );
            }
            return ListView.separated(
              itemCount: orders.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = orders[index];
                return InkWell(
                  onTap: () => context.push(RouteNames.orderDetailPath(order.id)),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary.withOpacity(0.08)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order #${order.id.shortId}',
                              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            OrderStatusBadge(status: order.orderStatus),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${order.items.length} items · ${formatOrderDate(order.createdAt)}',
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondaryLight),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          order.grandTotal.formatted,
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
