import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/route_names.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/extensions.dart';
import '../../../domain/entities/order_entity.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../../shared/widgets/order_status_badge.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import '../controllers/admin_dashboard_controller.dart';

/// `null` means "All" — kept out of [OrderStatus] itself since it isn't a
/// real order state, just a UI filter option.
class AllOrdersScreen extends ConsumerStatefulWidget {
  const AllOrdersScreen({super.key});

  @override
  ConsumerState<AllOrdersScreen> createState() => _AllOrdersScreenState();
}

class _AllOrdersScreenState extends ConsumerState<AllOrdersScreen> {
  OrderStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(allOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: Text('All Orders', style: GoogleFonts.poppins(fontWeight: FontWeight.bold))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FilterChip(label: 'All', selected: _filter == null, onTap: () => setState(() => _filter = null)),
                for (final status in OrderStatus.values)
                  _FilterChip(
                    label: status.label,
                    selected: _filter == status,
                    onTap: () => setState(() => _filter = status),
                  ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(allOrdersProvider),
              child: ordersAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: ListShimmerLoader(itemHeight: 88),
                ),
                error: (e, _) => ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    ErrorStateWidget(
                      message: 'Couldn\'t load orders: $e',
                      onRetry: () => ref.invalidate(allOrdersProvider),
                    ),
                  ],
                ),
                data: (orders) {
                  final filtered = _filter == null ? orders : orders.where((o) => o.orderStatus == _filter).toList();

                  if (filtered.isEmpty) {
                    return ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: [
                        EmptyStateWidget(
                          icon: Icons.receipt_long_outlined,
                          title: _filter == null ? 'No orders yet' : 'No ${_filter!.label.toLowerCase()} orders',
                        ),
                      ],
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final order = filtered[index];
                      return InkWell(
                        onTap: () => context.push(RouteNames.adminOrderManagementPath(order.id)),
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
                                order.shopName,
                                style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.primary),
                              ),
                              const SizedBox(height: 4),
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
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary.withOpacity(0.15),
      checkmarkColor: AppColors.primary,
      labelStyle: GoogleFonts.inter(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: selected ? AppColors.primary : null,
      ),
    );
  }
}
