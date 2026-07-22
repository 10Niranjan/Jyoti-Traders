import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import '../controllers/admin_dashboard_controller.dart';
import '../controllers/admin_retailer_controller.dart';
import '../widgets/retailer_summary_tile.dart';

class RetailerListScreen extends ConsumerWidget {
  const RetailerListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summariesAsync = ref.watch(retailerSummariesProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Retailers', style: GoogleFonts.poppins(fontWeight: FontWeight.bold))),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(approvedUsersProvider);
          ref.invalidate(allOrdersProvider);
        },
        child: summariesAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(18.0),
            child: ListShimmerLoader(itemCount: 6, itemHeight: 84),
          ),
          error: (e, _) => ListView(
            padding: const EdgeInsets.all(18.0),
            children: [
              ErrorStateWidget(
                message: 'Couldn\'t load retailers: $e',
                onRetry: () {
                  ref.invalidate(approvedUsersProvider);
                  ref.invalidate(allOrdersProvider);
                },
              ),
            ],
          ),
          data: (summaries) {
            if (summaries.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(18.0),
                children: const [
                  EmptyStateWidget(
                    icon: Icons.storefront_outlined,
                    title: 'No approved retailers yet',
                    message: 'Retailers you approve will show up here with their order history.',
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(18.0),
              itemCount: summaries.length,
              itemBuilder: (context, index) => RetailerSummaryTile(summary: summaries[index]),
            );
          },
        ),
      ),
    );
  }
}
