import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/user_model.dart';
import '../../../domain/entities/bank_details_entity.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/primary_button.dart';
import 'edit_sheet_frame.dart';

/// Bank account and UPI ID for payouts.
class PayoutSheet extends ConsumerStatefulWidget {
  final UserModel user;

  const PayoutSheet({super.key, required this.user});

  @override
  ConsumerState<PayoutSheet> createState() => _PayoutSheetState();
}

class _PayoutSheetState extends ConsumerState<PayoutSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _holder;
  late final TextEditingController _account;
  late final TextEditingController _ifsc;
  late final TextEditingController _bank;
  late final TextEditingController _upi;
  late final List<String> _initial;
  bool _saving = false;
  String? _error;

  List<TextEditingController> get _all => [_holder, _account, _ifsc, _bank, _upi];

  @override
  void initState() {
    super.initState();
    final b = widget.user.bankDetails;
    _holder = TextEditingController(text: b?.accountHolderName ?? '');
    _account = TextEditingController(text: b?.accountNumber ?? '');
    _ifsc = TextEditingController(text: b?.ifscCode ?? '');
    _bank = TextEditingController(text: b?.bankName ?? '');
    _upi = TextEditingController(text: b?.upiId ?? '');
    _initial = _all.map((c) => c.text).toList();
  }

  @override
  void dispose() {
    for (final c in _all) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _dirty {
    final now = _all.map((c) => c.text.trim()).toList();
    for (var i = 0; i < now.length; i++) {
      if (now[i] != _initial[i].trim()) return true;
    }
    return false;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() {
      _saving = true;
      _error = null;
    });
    final anyInput = _all.any((c) => c.text.trim().isNotEmpty);
    final error = await runProfileSave(
      ref,
      l10n,
      (c) => c.updateProfile(
        uid: widget.user.uid,
        bankDetails: anyInput
            ? BankDetailsEntity(
                accountHolderName: _holder.text.trim(),
                accountNumber: _account.text.trim(),
                ifscCode: _ifsc.text.trim().toUpperCase(),
                bankName: _bank.text.trim(),
                upiId: _upi.text.trim().isEmpty ? null : _upi.text.trim(),
              )
            : null,
      ),
    );
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _saving = false;
        _error = error;
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
      title: l10n.profilePayoutDetails,
      dirty: _dirty,
      child: Form(
        key: _formKey,
        onChanged: () => setState(() {}),
        child: Column(
          children: [
            const SizedBox(height: 8),
            TextFormField(
              controller: _holder,
              decoration: InputDecoration(
                labelText: l10n.profileAccountHolderName,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _account,
              decoration: InputDecoration(
                labelText: l10n.profileAccountNumber,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: Validators.bankAccountNumber,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _ifsc,
              decoration: InputDecoration(labelText: l10n.profileIfscCode),
              textCapitalization: TextCapitalization.characters,
              validator: Validators.ifscCode,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _bank,
              decoration: InputDecoration(labelText: l10n.profileBankName),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _upi,
              decoration: InputDecoration(
                labelText: l10n.profileUpiIdOptional,
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _error!,
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
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
