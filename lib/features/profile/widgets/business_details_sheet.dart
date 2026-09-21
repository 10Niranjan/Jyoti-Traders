import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/user_model.dart';
import '../../../domain/entities/business_hours_entity.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/primary_button.dart';
import 'edit_sheet_frame.dart';

/// GST number and opening hours.
class BusinessDetailsSheet extends ConsumerStatefulWidget {
  final UserModel user;

  const BusinessDetailsSheet({super.key, required this.user});

  @override
  ConsumerState<BusinessDetailsSheet> createState() =>
      _BusinessDetailsSheetState();
}

class _BusinessDetailsSheetState extends ConsumerState<BusinessDetailsSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _gst;
  late final String _initialGst;
  late final BusinessHoursEntity _initialHours;
  late bool _is24x7;
  late String _open;
  late String _close;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initialGst = widget.user.gstNumber ?? '';
    _initialHours = widget.user.businessHours ?? BusinessHoursEntity.defaults;
    _gst = TextEditingController(text: _initialGst);
    _is24x7 = _initialHours.is24x7;
    _open = _initialHours.openTime;
    _close = _initialHours.closeTime;
  }

  @override
  void dispose() {
    _gst.dispose();
    super.dispose();
  }

  bool get _dirty =>
      _gst.text.trim() != _initialGst ||
      _is24x7 != _initialHours.is24x7 ||
      // Hours only matter while not open 24x7, so ignore them then.
      (!_is24x7 &&
          (_open != _initialHours.openTime ||
              _close != _initialHours.closeTime));

  TimeOfDay _parse(String hhmm) {
    final parts = hhmm.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _display(String hhmm) {
    final t = _parse(hhmm);
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    final hour12 = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    return '${hour12.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} $period';
  }

  Future<void> _pick(bool isOpen) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _parse(isOpen ? _open : _close),
    );
    if (picked == null) return;
    final formatted =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    setState(() => isOpen ? _open = formatted : _close = formatted);
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
    final gst = _gst.text.trim();
    final error = await runProfileSave(
      ref,
      l10n,
      (c) => c.updateProfile(
        uid: widget.user.uid,
        gstNumber: gst.isEmpty ? null : gst,
        businessHours: BusinessHoursEntity(
          openTime: _open,
          closeTime: _close,
          is24x7: _is24x7,
        ),
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
      title: l10n.profileBusinessDetails,
      dirty: _dirty,
      child: Form(
        key: _formKey,
        onChanged: () => setState(() {}),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            TextFormField(
              controller: _gst,
              decoration: InputDecoration(labelText: l10n.profileGstNumber),
              textCapitalization: TextCapitalization.characters,
              validator: Validators.gstNumber,
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.profileOpen24x7),
              value: _is24x7,
              onChanged: (v) => setState(() => _is24x7 = v),
            ),
            if (!_is24x7) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pick(true),
                      child: Text(l10n.profileOpensAt(_display(_open))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pick(false),
                      child: Text(l10n.profileClosesAt(_display(_close))),
                    ),
                  ),
                ],
              ),
            ],
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
