import 'package:flutter/material.dart';
import '../../../core/theme/theme_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/business_profile_entity.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../profile/widgets/edit_sheet_frame.dart';
import '../../settings/controllers/business_profile_controller.dart';

/// The owner's legal name, registered address and GSTIN — the seller block on
/// every invoice. Shares the profile sheets' unsaved-changes guard.
class BusinessProfileSheet extends ConsumerStatefulWidget {
  final BusinessProfileEntity initial;

  const BusinessProfileSheet({super.key, required this.initial});

  @override
  ConsumerState<BusinessProfileSheet> createState() =>
      _BusinessProfileSheetState();
}

class _BusinessProfileSheetState extends ConsumerState<BusinessProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _address;
  late final TextEditingController _gstin;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initial.legalName);
    _address = TextEditingController(text: widget.initial.address);
    _gstin = TextEditingController(text: widget.initial.gstin);
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _gstin.dispose();
    super.dispose();
  }

  BusinessProfileEntity get _current => BusinessProfileEntity(
    legalName: _name.text.trim(),
    address: _address.text.trim(),
    gstin: _gstin.text.trim().toUpperCase(),
  );

  bool get _dirty => _current != widget.initial;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() {
      _saving = true;
      _error = null;
    });
    final controller = ref.read(businessProfileControllerProvider.notifier);
    await controller.save(_current);
    if (!mounted) return;
    final result = ref.read(businessProfileControllerProvider);
    if (result.hasError) {
      setState(() {
        _saving = false;
        _error = l10n.profileUpdateFailed(result.error.toString());
      });
      return;
    }
    navigator.pop();
    messenger.showSnackBar(SnackBar(content: Text(l10n.profileSectionSaved)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return EditSheetFrame(
      title: l10n.profileBusinessDetails,
      dirty: _dirty,
      child: Form(
        key: _formKey,
        onChanged: () => setState(() {}),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.adminBusinessPrintedOnInvoices,
              style: TextStyle(fontSize: 12, color: context.textSecondary),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _name,
              decoration: InputDecoration(
                labelText: l10n.adminBusinessLegalName,
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _address,
              decoration: InputDecoration(labelText: l10n.adminBusinessAddress),
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _gstin,
              decoration: InputDecoration(labelText: l10n.profileGstNumber),
              textCapitalization: TextCapitalization.characters,
              validator: Validators.gstNumber,
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: AppColors.error)),
            ],
            const SizedBox(height: 20),
            PrimaryButton(
              label: l10n.profileSaveChanges,
              isLoading: _saving,
              onPressed: _dirty ? _save : null,
            ),
          ],
        ),
      ),
    );
  }
}
