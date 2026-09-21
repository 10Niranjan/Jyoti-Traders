import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/route_names.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../l10n/app_localizations.dart';
import '../controllers/search_controller.dart';
import '../widgets/search_field.dart';
import '../widgets/search_results_view.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchControllerProvider);
    final notifier = ref.read(searchControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        // Search is a shell tab, so there is no route to pop; back means
        // "return to Home", closing the autofocus keyboard on the way out.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () {
            FocusManager.instance.primaryFocus?.unfocus();
            context.go(RouteNames.home);
          },
        ),
        title: const Padding(
          padding: EdgeInsets.only(right: 16),
          child: SearchField(autofocus: true),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: state.query.trim().isEmpty
            ? _RecentSearches(
                terms: state.recentSearches,
                onTapTerm: notifier.onQueryChanged,
                onClear: notifier.clearRecentSearches,
              )
            : const SearchResultsView(),
      ),
    );
  }
}

class _RecentSearches extends StatelessWidget {
  final List<String> terms;
  final ValueChanged<String> onTapTerm;
  final VoidCallback onClear;

  const _RecentSearches({
    required this.terms,
    required this.onTapTerm,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (terms.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.search_rounded,
        title: l10n.searchEmptyTitle,
        message: l10n.searchEmptyMessage,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.searchRecentSearches,
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            TextButton(onPressed: onClear, child: Text(l10n.searchClear)),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: terms
              .map(
                (term) => ActionChip(
                  label: Text(term),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                    side: BorderSide(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                  elevation: 0,
                  onPressed: () => onTapTerm(term),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
