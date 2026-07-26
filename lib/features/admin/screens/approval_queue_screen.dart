import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import '../controllers/admin_dashboard_controller.dart';
import '../widgets/empty_approval_queue_card.dart';
import '../widgets/retailer_approval_card.dart';

/// Full retailer approval queue — a live stream of every pending
/// sign-up, reachable from the dashboard's "View All" link.
class ApprovalQueueScreen extends ConsumerWidget {
  const ApprovalQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingUsers = ref.watch(pendingUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Retailer Approval Queue',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(pendingUsersProvider),
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(pendingUsersProvider),
        child: pendingUsers.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(18.0),
            child: ListShimmerLoader(itemCount: 5, itemHeight: 140),
          ),
          error: (e, _) => ListView(
            padding: const EdgeInsets.all(18.0),
            children: [
              ErrorStateWidget(
                message: 'Couldn\'t load approval queue: $e',
                onRetry: () => ref.invalidate(pendingUsersProvider),
              ),
            ],
          ),
          data: (users) => users.isEmpty
              ? ListView(
                  padding: const EdgeInsets.all(18.0),
                  children: const [EmptyApprovalQueueCard()],
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(18.0),
                  itemCount: users.length,
                  itemBuilder: (context, idx) =>
                      RetailerApprovalCard(user: users[idx], index: idx),
                ),
        ),
      ),
    );
  }
}
