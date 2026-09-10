import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/route_names.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../../shared/widgets/notification_bell_button.dart';
import '../controllers/admin_dashboard_controller.dart';
import '../widgets/admin_stat_card.dart';
import '../widgets/category_revenue_chart.dart';
import '../widgets/empty_approval_queue_card.dart';
import '../widgets/order_status_funnel.dart';
import '../widgets/orders_bar_chart.dart';
import '../widgets/retailer_approval_card.dart';
import '../widgets/retailer_growth_chart.dart';

/// Preview cap for the dashboard's inline approval queue — the full list
/// lives on [ApprovalQueueScreen] (4.2), reached via "View All".
const _queuePreviewLimit = 3;

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pendingUsers = ref.watch(pendingUsersProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.adminDashboardTitle,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        actions: [const NotificationBellButton()],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: AdminStatCard(
                      title: l10n.adminPendingApprovals,
                      value: ref.watch(pendingApprovalsCountProvider),
                      icon: Icons.pending_actions_outlined,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AdminStatCard(
                      title: l10n.adminTotalRetailers,
                      value: ref.watch(totalRetailersCountProvider),
                      icon: Icons.storefront_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AdminStatCard(
                      title: l10n.adminTodaysOrders,
                      value: ref.watch(todayOrderCountProvider),
                      icon: Icons.shopping_bag_outlined,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AdminStatCard(
                      title: l10n.adminTodaysRevenue,
                      value: ref.watch(todayRevenueProvider),
                      icon: Icons.payments_outlined,
                      color: AppColors.accent,
                      formatter: (v) => formatRupees(v.toDouble()),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const OrdersBarChart(),
              const SizedBox(height: 12),
              const CategoryRevenueChart(),
              const SizedBox(height: 12),
              const RetailerGrowthChart(),
              const SizedBox(height: 12),
              const OrderStatusFunnel(),

              const SizedBox(height: 20),
              Text(
                l10n.adminTopProducts,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),
              ref
                  .watch(topProductsProvider)
                  .when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, _) =>
                        Text(l10n.adminCouldntLoadTopProducts('$e')),
                    data: (products) => products.isEmpty
                        ? Text(
                            l10n.adminNoSalesYet,
                            style: GoogleFonts.inter(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          )
                        : Column(
                            children: [
                              for (final p in products)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          p.name,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            color: isDark
                                                ? AppColors.textPrimaryDark
                                                : AppColors.textPrimaryLight,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        formatRupees(p.revenue),
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                  ),

              const SizedBox(height: 20),
              // "Manage Products", "Manage Categories", "All Orders" and
              // "Retailers" dropped here (Phase 9.2/9.4) — the Catalog/
              // Orders/Retailers bottom-nav tabs reach the same screens now.
              // Delivery Settings stays until 9.6 gives it a tab home.
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      context.push(RouteNames.adminDeliverySettings),
                  icon: const Icon(Icons.local_shipping_outlined, size: 18),
                  label: Text(l10n.adminDeliverySettingsTitle),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.push(RouteNames.adminBroadcast),
                  icon: const Icon(Icons.campaign_outlined, size: 18),
                  label: Text(l10n.adminSendBroadcast),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.adminRetailerApprovalQueue,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        context.push(RouteNames.adminApprovalQueue),
                    child: Text(l10n.adminViewAll),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              pendingUsers.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (e, _) => ErrorStateWidget(
                  message: l10n.adminCouldntLoadApprovalQueue('$e'),
                  onRetry: () => ref.invalidate(pendingUsersProvider),
                ),
                data: (users) => users.isEmpty
                    ? const EmptyApprovalQueueCard()
                    : Column(
                        children: [
                          for (
                            var i = 0;
                            i < users.length && i < _queuePreviewLimit;
                            i++
                          )
                            RetailerApprovalCard(user: users[i], index: i),
                          if (users.length > _queuePreviewLimit)
                            Padding(
                              padding: const EdgeInsets.only(top: 4, bottom: 8),
                              child: Text(
                                l10n.adminMoreWaiting(
                                  users.length - _queuePreviewLimit,
                                ),
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
