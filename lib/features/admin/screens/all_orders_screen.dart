import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/route_names.dart';
import '../../../core/utils/csv_encoder.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/extensions.dart';
import '../../../domain/entities/order_entity.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../../shared/widgets/order_status_badge.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import '../../../shared/widgets/status_filter_chip.dart';
import '../controllers/admin_dashboard_controller.dart';

/// `null` filter means "All" — kept out of [OrderStatus] itself since it
/// isn't a real order state, just a UI filter option.
///
/// When [retailerId] is set, the list is additionally scoped to that
/// retailer's orders only — used by the Retailers tab's Approved segment
/// "view history" tap-through, reusing this screen's list/filter UI rather
/// than a near-duplicate.
class AllOrdersScreen extends ConsumerStatefulWidget {
  final String? retailerId;

  const AllOrdersScreen({super.key, this.retailerId});

  @override
  ConsumerState<AllOrdersScreen> createState() => _AllOrdersScreenState();
}

class _AllOrdersScreenState extends ConsumerState<AllOrdersScreen> {
  OrderStatus? _filter;

  List<OrderEntity> _filteredOrders(List<OrderEntity> orders) {
    final scoped = widget.retailerId == null
        ? orders
        : orders.where((o) => o.userId == widget.retailerId).toList();
    return _filter == null
        ? scoped
        : scoped.where((o) => o.orderStatus == _filter).toList();
  }

  Future<void> _exportCsv(List<OrderEntity> orders) async {
    if (orders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No orders to export.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final rows = <List<Object?>>[
      [
        'Order ID',
        'Shop Name',
        'Items',
        'Subtotal',
        'Delivery Charge',
        'Grand Total',
        'Payment Method',
        'Payment Status',
        'Order Status',
        'Placed At',
      ],
      for (final o in orders)
        [
          o.id,
          o.shopName,
          o.items.length,
          o.subtotal.amount,
          o.deliveryCharge.amount,
          o.grandTotal.amount,
          o.paymentMethod.value,
          o.paymentStatus.value,
          o.orderStatus.value,
          o.createdAt.toIso8601String(),
        ],
    ];
    final csv = encodeCsv(rows);
    // Wrapped defensively like every other platform-plugin call in this
    // codebase (FcmService, LocationService, ImageUploadService) — the share
    // sheet isn't available on every platform or in a test environment.
    try {
      await Share.shareXFiles([
        XFile.fromData(
          utf8.encode(csv),
          name: 'orders_export.csv',
          mimeType: 'text/csv',
        ),
      ], subject: 'Orders Export');
    } catch (e) {
      debugPrint('AllOrdersScreen: export share sheet unavailable: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(allOrdersProvider);
    final retailerId = widget.retailerId;

    final title = retailerId == null
        ? 'All Orders'
        : ref
              .watch(approvedUsersProvider)
              .maybeWhen(
                data: (users) {
                  final match = users.where((u) => u.uid == retailerId);
                  return match.isEmpty
                      ? 'Retailer Orders'
                      : '${match.first.shopName} — Orders';
                },
                orElse: () => 'Retailer Orders',
              );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share_rounded),
            tooltip: 'Export as CSV',
            onPressed: () => _exportCsv(
              _filteredOrders(ordersAsync.valueOrNull ?? const []),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StatusFilterChip(
                  label: 'All',
                  selected: _filter == null,
                  onTap: () => setState(() => _filter = null),
                ),
                for (final status in OrderStatus.values)
                  StatusFilterChip(
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
                  final filtered = _filteredOrders(orders);

                  if (filtered.isEmpty) {
                    return ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: [
                        EmptyStateWidget(
                          icon: Icons.receipt_long_outlined,
                          title: _filter == null
                              ? 'No orders yet'
                              : 'No ${_filter!.label.toLowerCase()} orders',
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
                        onTap: () => context.push(
                          RouteNames.adminOrderManagementPath(order.id),
                        ),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.08),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Order #${order.id.shortId}',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  OrderStatusBadge(status: order.orderStatus),
                                ],
                              ),
                              if (retailerId == null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  order.shopName,
                                  style: GoogleFonts.inter(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 4),
                              Text(
                                '${order.items.length} items · ${formatOrderDate(order.createdAt)}',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                order.grandTotal.formatted,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: AppColors.primary,
                                ),
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
