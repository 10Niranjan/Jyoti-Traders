import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../controllers/profile_controller.dart';

/// Opens a profile edit sheet. Drag-to-dismiss is off: a drag closes the route
/// with `Navigator.pop`, which would skip [EditSheetFrame]'s "Discard
/// changes?" guard and silently throw away what was typed. Back, the scrim
/// tap and the ✕ button all go through the guard.
Future<void> showEditSheet(BuildContext context, {required Widget child}) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    enableDrag: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => child,
  );
}

/// True when the retailer chose to throw their edits away.
Future<bool> confirmDiscardChanges(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final discard = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(
        l10n.profileDiscardTitle,
        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 17),
      ),
      content: Text(
        l10n.profileDiscardMessage,
        style: GoogleFonts.inter(fontSize: 13),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.profileKeepEditing),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(
            l10n.profileDiscardAction,
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ],
    ),
  );
  return discard ?? false;
}

/// Title bar, keyboard-safe scrolling body and the unsaved-changes guard, so
/// every edit sheet behaves the same. While [dirty], leaving the sheet asks
/// first; clean sheets close immediately.
class EditSheetFrame extends StatelessWidget {
  final String title;
  final bool dirty;
  final Widget child;

  const EditSheetFrame({
    super.key,
    required this.title,
    required this.dirty,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final discard = await confirmDiscardChanges(context);
        // `pop`, not `maybePop`: the guard has already been answered.
        if (discard && context.mounted) Navigator.of(context).pop();
      },
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).closeButtonTooltip,
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ],
                ),
                Padding(padding: const EdgeInsets.only(right: 8), child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Runs a profile save and reports failure as text for the sheet to show
/// *inside itself* — a snackbar would render behind the modal sheet, where the
/// retailer can't see it. Null means it worked.
///
/// Relies on the profile screen underneath keeping the (autoDispose)
/// `profileControllerProvider` watched while the sheet is open.
Future<String?> runProfileSave(
  WidgetRef ref,
  AppLocalizations l10n,
  Future<void> Function(ProfileController controller) save,
) async {
  await save(ref.read(profileControllerProvider.notifier));
  final result = ref.read(profileControllerProvider);
  return result.hasError
      ? l10n.profileUpdateFailed(result.error.toString())
      : null;
}
