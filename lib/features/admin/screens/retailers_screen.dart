import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../controllers/admin_dashboard_controller.dart';
import 'approval_queue_screen.dart';
import 'approved_retailers_list_view.dart';

/// Admin "Retailers" tab (Phase 9.5) — approved retailers and the pending
/// approval queue folded into one destination via a segmented `TabBar`,
/// same pattern as the Catalog tab (9.4) and `AdminProfileScreen`.
class RetailersScreen extends ConsumerStatefulWidget {
  const RetailersScreen({super.key});

  @override
  ConsumerState<RetailersScreen> createState() => _RetailersScreenState();
}

class _RetailersScreenState extends ConsumerState<RetailersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unselectedColor = Theme.of(
      context,
    ).colorScheme.onSurface.withOpacity(0.6);
    final pendingCount =
        ref.watch(pendingApprovalsCountProvider).valueOrNull ?? 0;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.adminRetailersTitle,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: unselectedColor,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(
              icon: const Icon(Icons.storefront_outlined),
              text: l10n.adminApprovedTab,
            ),
            Tab(
              icon: const Icon(Icons.pending_actions_outlined),
              text: pendingCount > 0
                  ? l10n.adminPendingTabWithCount(pendingCount)
                  : l10n.adminPendingTab,
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ApprovedRetailersListView(),
          PendingRetailersListView(),
        ],
      ),
    );
  }
}
