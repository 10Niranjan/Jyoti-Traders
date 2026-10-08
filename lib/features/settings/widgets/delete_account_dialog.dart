import 'package:flutter/material.dart';
import '../../../core/theme/theme_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../profile/controllers/profile_controller.dart';

/// "Delete your account?" — explains what goes and what stays, and asks for
/// the password before doing anything irreversible. Firebase needs it anyway
/// to re-authenticate a session that isn't fresh.
///
/// On success the auth stream signs the user out and the app routes to login,
/// so this dialog is torn down with the screen and never needs to close
/// itself; on failure it stays open and shows why.
class DeleteAccountDialog extends ConsumerStatefulWidget {
  final String uid;

  const DeleteAccountDialog({super.key, required this.uid});

  @override
  ConsumerState<DeleteAccountDialog> createState() =>
      _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<DeleteAccountDialog> {
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _busy = true;
      _error = null;
    });
    final controller = ref.read(profileControllerProvider.notifier);
    final ok = await controller.deleteAccount(
      uid: widget.uid,
      password: _password.text,
    );
    if (!mounted) return; // success: the screen is already gone
    if (ok) {
      Navigator.of(context).pop();
      return;
    }
    final error = ref.read(profileControllerProvider).error;
    setState(() {
      _busy = false;
      _error = l10n.settingsDeleteFailed('$error');
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(
        l10n.settingsDeleteTitle,
        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 17),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.settingsDeleteMessage,
              style: GoogleFonts.inter(fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _password,
              obscureText: true,
              enabled: !_busy,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: l10n.settingsDeletePasswordLabel,
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(color: AppColors.error, fontSize: 12.5),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancelButton),
        ),
        TextButton(
          onPressed: (_busy || _password.text.isEmpty) ? null : _delete,
          child: _busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  l10n.settingsDeleteAction,
                  style: TextStyle(
                    color: _password.text.isEmpty
                        ? context.textSecondary
                        : AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ],
    );
  }
}
