import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/route_names.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../../shared/widgets/notification_bell_button.dart';
import '../controllers/admin_dashboard_controller.dart';
import '../widgets/admin_stat_card.dart';
import '../widgets/empty_approval_queue_card.dart';
import '../widgets/orders_bar_chart.dart';
import '../widgets/retailer_approval_card.dart';

/// Preview cap for the dashboard's inline approval queue — the full list
/// lives on [ApprovalQueueScreen] (4.2), reached via "View All".
const _queuePreviewLimit = 3;

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pendingUsers = ref.watch(pendingUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Jyoti Traders Admin',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
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
                      title: 'Pending Approvals',
                      value: ref.watch(pendingApprovalsCountProvider),
                      icon: Icons.pending_actions_outlined,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AdminStatCard(
                      title: 'Total Retailers',
                      value: ref.watch(totalRetailersCountProvider),
                      icon: Icons.storefront_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AdminStatCard(
                title: "Today's Orders",
                value: ref.watch(todayOrderCountProvider),
                icon: Icons.shopping_bag_outlined,
                color: AppColors.success,
              ),

              const SizedBox(height: 20),
              const OrdersBarChart(),

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
                  label: const Text('Delivery Settings'),
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
                    'Retailer Approval Queue',
                    style: GoogleFonts.poppins(
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
                    child: const Text('View All'),
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
                  message: 'Couldn\'t load approval queue: $e',
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
                                '+${users.length - _queuePreviewLimit} more waiting — tap "View All"',
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
