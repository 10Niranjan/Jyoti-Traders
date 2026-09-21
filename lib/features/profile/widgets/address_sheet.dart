import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/geocoding_service.dart';
import '../../../core/services/location_service.dart';
import '../../../data/models/user_model.dart';
import '../../../domain/entities/address_entity.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/address_form_fields.dart';
import '../../../shared/widgets/primary_button.dart';
import 'edit_sheet_frame.dart';

/// Edit the shop's delivery address: street/city/pincode, "use current
/// location" (which is what unlocks per-km delivery pricing), and a Home /
/// Shop / Warehouse label.
class AddressSheet extends ConsumerStatefulWidget {
  final UserModel user;

  const AddressSheet({super.key, required this.user});

  @override
  ConsumerState<AddressSheet> createState() => _AddressSheetState();
}

class _AddressSheetState extends ConsumerState<AddressSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _street;
  late final TextEditingController _city;
  late final TextEditingController _pincode;
  late final AddressEntity? _initial;
  double? _latitude;
  double? _longitude;
  String? _resolvedAddress;
  String? _label;
  bool _isLocating = false;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final a = _initial = widget.user.address;
    _street = TextEditingController(text: a?.street ?? '');
    _city = TextEditingController(text: a?.city ?? '');
    _pincode = TextEditingController(text: a?.pincode ?? '');
    _latitude = a?.latitude;
    _longitude = a?.longitude;
    _resolvedAddress = a?.formattedAddress;
    _label = a?.label;
  }

  @override
  void dispose() {
    _street.dispose();
    _city.dispose();
    _pincode.dispose();
    super.dispose();
  }

  bool get _dirty =>
      _street.text.trim() != (_initial?.street ?? '') ||
      _city.text.trim() != (_initial?.city ?? '') ||
      _pincode.text.trim() != (_initial?.pincode ?? '') ||
      _latitude != _initial?.latitude ||
      _longitude != _initial?.longitude ||
      (_label ?? '') != (_initial?.label ?? '');

  Future<void> _useCurrentLocation() async {
    setState(() => _isLocating = true);
    final position = await ref
        .read(locationServiceProvider)
        .getCurrentPosition();
    if (position == null) {
      if (!mounted) return;
      setState(() {
        _isLocating = false;
        _error = AppLocalizations.of(context)!.checkoutLocationError;
      });
      return;
    }
    final resolved = await ref
        .read(geocodingServiceProvider)
        .reverseGeocode(
          latitude: position.latitude,
          longitude: position.longitude,
        );
    if (!mounted) return;
    setState(() {
      _isLocating = false;
      _error = null;
      _latitude = position.latitude;
      _longitude = position.longitude;
      if (resolved != null) {
        _resolvedAddress = resolved.formattedAddress;
        // Only fills what's empty — never overwrites something typed.
        if (_street.text.trim().isEmpty && resolved.street != null) {
          _street.text = resolved.street!;
        }
        if (_city.text.trim().isEmpty && resolved.city != null) {
          _city.text = resolved.city!;
        }
        if (_pincode.text.trim().isEmpty && resolved.pincode != null) {
          _pincode.text = resolved.pincode!;
        }
      }
    });
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
    final error = await runProfileSave(
      ref,
      l10n,
      (c) => c.updateProfile(
        uid: widget.user.uid,
        address: AddressEntity(
          street: _street.text.trim(),
          city: _city.text.trim(),
          pincode: _pincode.text.trim(),
          latitude: _latitude,
          longitude: _longitude,
          formattedAddress: _resolvedAddress,
          id: _initial?.id,
          label: _label,
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
    final labels = [
      l10n.profileLabelHome,
      l10n.profileLabelShop,
      l10n.profileLabelWarehouse,
    ];
    return EditSheetFrame(
      title: l10n.checkoutDeliveryAddress,
      dirty: _dirty,
      child: Form(
        key: _formKey,
        onChanged: () => setState(() {}),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final label in labels)
                  ChoiceChip(
                    label: Text(label),
                    selected: _label == label,
                    // Tap again to clear — a label is optional.
                    onSelected: (on) => setState(() => _label = on ? label : null),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            AddressFormFields(
              streetController: _street,
              cityController: _city,
              pincodeController: _pincode,
              resolvedAddress: _resolvedAddress,
              isLocating: _isLocating,
              onUseCurrentLocation: _useCurrentLocation,
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
