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

/// Gradient header band + keyboard-safe scrolling body + the unsaved-changes
/// guard, so every edit sheet behaves and looks the same — same icon-badge
/// treatment as the Settings pop-ups ([showSettingsPopup]'s `_Header`), just
/// anchored to the top of a bottom sheet instead of a centered card, since a
/// form with a keyboard needs the sheet's resize-with-keyboard behaviour a
/// centered dialog doesn't give for free.
/// While [dirty], leaving the sheet asks first; clean sheets close immediately.
class EditSheetFrame extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool dirty;
  final Widget child;

  const EditSheetFrame({
    super.key,
    required this.title,
    required this.icon,
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SheetHeader(title: title, icon: icon),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The saffron gradient band across the top of an edit sheet — an icon badge,
/// the title, and a close button. Visually the same language as
/// [showSettingsPopup]'s header, scaled down for a sheet instead of a card.
/// Public so other bottom sheets outside the profile-edit family (e.g. the
/// admin banner editor) can match the same look without duplicating it.
class SheetHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const SheetHeader({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryDark, AppColors.primary],
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 10, 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.20),
                border: Border.all(color: Colors.white.withOpacity(0.36)),
              ),
              child: Icon(icon, size: 22, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white),
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
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
