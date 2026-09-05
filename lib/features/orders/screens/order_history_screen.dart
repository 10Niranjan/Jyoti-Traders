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
import '../../../shared/widgets/status_filter_chip.dart';
import '../../../l10n/app_localizations.dart';
import '../controllers/order_controller.dart';

class OrderHistoryScreen extends ConsumerStatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  ConsumerState<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends ConsumerState<OrderHistoryScreen> {
  OrderStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(orderHistoryProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.orderHistoryTitle)),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(orderHistoryProvider),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    StatusFilterChip(
                      label: l10n.orderHistoryFilterAll,
                      selected: _filter == null,
                      onTap: () => setState(() => _filter = null),
                    ),
                    for (final status in OrderStatus.values) ...[
                      const SizedBox(width: 8),
                      StatusFilterChip(
                        label: status.label,
                        selected: _filter == status,
                        onTap: () => setState(() => _filter = status),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: ordersAsync.when(
                  loading: () => const ListShimmerLoader(itemHeight: 88),
                  error: (error, stack) => ListView(
                    children: [
                      ErrorStateWidget(
                        onRetry: () => ref.invalidate(orderHistoryProvider),
                      ),
                    ],
                  ),
                  data: (orders) {
                    final filtered = _filter == null
                        ? orders
                        : orders
                              .where((o) => o.orderStatus == _filter)
                              .toList();

                    if (filtered.isEmpty) {
                      return ListView(
                        children: [
                          EmptyStateWidget(
                            icon: Icons.receipt_long_outlined,
                            title: _filter == null
                                ? l10n.orderHistoryEmptyTitle
                                : l10n.orderHistoryEmptyFiltered(_filter!.label.toLowerCase()),
                            message: _filter == null
                                ? l10n.orderHistoryEmptyMessage
                                : null,
                          ),
                        ],
                      );
                    }
                    return ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final order = filtered[index];
                        return InkWell(
                          onTap: () => context.push(
                            RouteNames.orderDetailPath(order.id),
                          ),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFF1F5F9)),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      l10n.orderNumber(order.id.shortId),
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    OrderStatusBadge(status: order.orderStatus),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  l10n.orderItemsAndDate(order.items.length, formatOrderDate(order.createdAt)),
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.textSecondaryLight,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  order.grandTotal.formatted,
                                  style: GoogleFonts.inter(
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
      ),
    );
  }
}
