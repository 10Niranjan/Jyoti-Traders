import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import '../controllers/admin_dashboard_controller.dart';
import '../widgets/empty_approval_queue_card.dart';
import '../widgets/retailer_approval_card.dart';

/// Standalone screen at `/admin/approval-queue` — no longer linked to from
/// the dashboard's own preview since the Retailers tab (Phase 9.5) embeds
/// [PendingRetailersListView] directly, but left in place (route + screen,
/// including its refresh action) as a working direct link.
class ApprovalQueueScreen extends ConsumerWidget {
  const ApprovalQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.adminRetailerApprovalQueue,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(pendingUsersProvider),
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            tooltip: AppLocalizations.of(context)!.adminRefreshTooltip,
          ),
        ],
      ),
      body: const PendingRetailersListView(),
    );
  }
}

/// The pending-retailer approval queue itself — no `Scaffold`/`AppBar` of its
/// own, so it can be embedded either inside [ApprovalQueueScreen] or, since
/// Phase 9.5, as the "Pending" segment of the admin Retailers tab. Pull-to-
/// refresh covers the same job [ApprovalQueueScreen]'s AppBar refresh button
/// does, so that button wasn't duplicated here.
class PendingRetailersListView extends ConsumerWidget {
  const PendingRetailersListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingUsers = ref.watch(pendingUsersProvider);
    final l10n = AppLocalizations.of(context)!;

    return RefreshIndicator(
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
              message: l10n.adminCouldntLoadApprovalQueue('$e'),
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
    );
  }
}
