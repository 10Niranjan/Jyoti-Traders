import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/entities/promo_banner_entity.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/primary_button.dart';
import '../controllers/admin_banner_controller.dart';

/// Opens the add/edit form. Pass [banner] to edit, omit it to add a new one.
Future<void> showBannerEditorSheet(
  BuildContext context, {
  PromoBannerEntity? banner,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => BannerEditorSheet(banner: banner),
  );
}

class BannerEditorSheet extends ConsumerStatefulWidget {
  final PromoBannerEntity? banner;

  const BannerEditorSheet({super.key, this.banner});

  @override
  ConsumerState<BannerEditorSheet> createState() => _BannerEditorSheetState();
}

class _BannerEditorSheetState extends ConsumerState<BannerEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.banner?.title);
  late final _body = TextEditingController(text: widget.banner?.body);
  late bool _isActive = widget.banner?.isActive ?? true;
  late DateTime? _endsAt = widget.banner?.endsAt;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _endsAt ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
    );
    if (picked == null) return;
    // Runs through the end of the chosen day, not its first second.
    setState(
      () =>
          _endsAt = DateTime(picked.year, picked.month, picked.day, 23, 59, 59),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final saved = await ref
        .read(adminBannerControllerProvider.notifier)
        .save(
          PromoBannerEntity(
            id: widget.banner?.id ?? const Uuid().v4(),
            title: _title.text.trim(),
            body: _body.text.trim(),
            isActive: _isActive,
            endsAt: _endsAt,
          ),
        );
    if (!mounted) return;
    if (saved) {
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(l10n.adminBannerSaved)));
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n.adminUpdateFailed(
              '${ref.read(adminBannerControllerProvider).error}',
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Watched (not just read) so the autoDispose controller stays alive for
    // the whole async save, and to drive the button's loading state.
    final isSaving = ref.watch(adminBannerControllerProvider).isLoading;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.banner == null
                    ? l10n.adminBannerAdd
                    : l10n.adminBannerEditTitle,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _title,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.broadcastTitleFieldLabel,
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l10n.adminBannerTitleRequired
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _body,
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.adminBannerBodyOptional,
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.adminBannerShowOnHome),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_outlined),
                title: Text(
                  _endsAt == null
                      ? l10n.adminBannerPickEndDate
                      : l10n.adminBannerUntil(formatOrderDate(_endsAt!)),
                ),
                trailing: _endsAt == null
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        tooltip: l10n.adminBannerClearDate,
                        onPressed: () => setState(() => _endsAt = null),
                      ),
                onTap: _pickEndDate,
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: l10n.save,
                isLoading: isSaving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
