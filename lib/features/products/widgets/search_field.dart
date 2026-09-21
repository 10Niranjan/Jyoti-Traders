import 'package:flutter/material.dart';
import '../../../core/theme/theme_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../controllers/search_controller.dart';

/// The one search input, used by both Home and the Search tab.
///
/// A single `TextField` carrying its own pill decoration (prefix icon, clear
/// button, borders) — deliberately not a `Container` wrapping an `Icon` and a
/// bare `TextField`. The app theme's `InputDecorationTheme` sets `filled` plus
/// `enabledBorder`/`focusedBorder`, which override a bare `InputBorder.none`
/// and paint a second box *inside* the container, leaving the icon outside it.
///
/// Both instances share `searchControllerProvider`, so the text is kept in
/// sync when the query changes from the other screen.
class SearchField extends ConsumerStatefulWidget {
  final bool autofocus;

  const SearchField({super.key, this.autofocus = false});

  @override
  ConsumerState<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends ConsumerState<SearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(searchControllerProvider).query,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(searchControllerProvider.select((s) => s.query), (_, query) {
      if (_controller.text != query) _controller.text = query;
    });
    final notifier = ref.read(searchControllerProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(999),
      borderSide: BorderSide(
        color: isDark ? AppColors.borderDark : AppColors.borderLight,
      ),
    );

    return SizedBox(
      height: 44,
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) => TextField(
          controller: _controller,
          autofocus: widget.autofocus,
          textInputAction: TextInputAction.search,
          onChanged: notifier.onQueryChanged,
          onSubmitted: notifier.commitToRecentSearches,
          decoration: InputDecoration(
            hintText: l10n.searchHint,
            isDense: true,
            filled: true,
            fillColor: isDark ? Colors.white10 : AppColors.backgroundLight,
            contentPadding: EdgeInsets.zero,
            border: border,
            enabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              size: 20,
              color: context.textSecondary,
            ),
            suffixIcon: _controller.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    tooltip: l10n.searchClear,
                    color: context.textSecondary,
                    onPressed: () {
                      _controller.clear();
                      notifier.onQueryChanged('');
                    },
                  ),
          ),
        ),
      ),
    );
  }
}
