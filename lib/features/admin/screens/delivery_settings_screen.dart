import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/location_service.dart';
import '../../../domain/entities/delivery_config_entity.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../controllers/admin_delivery_config_controller.dart';

/// Standalone screen at `/admin/delivery-settings` — no longer linked to
/// from anywhere in-app since the Profile tab (Phase 9.6) embeds
/// [DeliveryConfigFormView] directly, but left in place (route + screen) as
/// a working direct link.
class DeliverySettingsScreen extends StatelessWidget {
  const DeliverySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Delivery Settings',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
      ),
      body: const DeliveryConfigFormView(),
    );
  }
}

/// Lets the admin set the warehouse's coordinates (every delivery charge is
/// measured from this point) and the per-km rate — phases.md §5. No
/// `Scaffold`/`AppBar` of its own, so it can be embedded either inside
/// [DeliverySettingsScreen] or, since Phase 9.6, as a section of the admin
/// Profile tab.
class DeliveryConfigFormView extends ConsumerStatefulWidget {
  const DeliveryConfigFormView({super.key});

  @override
  ConsumerState<DeliveryConfigFormView> createState() =>
      _DeliveryConfigFormViewState();
}

class _DeliveryConfigFormViewState
    extends ConsumerState<DeliveryConfigFormView> {
  final _formKey = GlobalKey<FormState>();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _rateController = TextEditingController();
  bool _seeded = false;
  bool _isLocating = false;

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  void _seedFrom(DeliveryConfigEntity config) {
    _latController.text = config.warehouseLat.toString();
    _lngController.text = config.warehouseLng.toString();
    _rateController.text = config.perKmRate.toString();
    _seeded = true;
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isLocating = true);
    final position = await ref
        .read(locationServiceProvider)
        .getCurrentPosition();
    if (!mounted) return;
    setState(() {
      _isLocating = false;
      if (position != null) {
        _latController.text = position.latitude.toString();
        _lngController.text = position.longitude.toString();
      }
    });
    if (position == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Couldn\'t get your location. Check location permission and try again.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  String? _validateCoordinate(String? v) {
    return double.tryParse(v?.trim() ?? '') == null
        ? 'Enter a valid coordinate'
        : null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final config = DeliveryConfigEntity(
      warehouseLat: double.parse(_latController.text.trim()),
      warehouseLng: double.parse(_lngController.text.trim()),
      perKmRate: double.parse(_rateController.text.trim()),
    );

    final success = await ref
        .read(adminDeliveryConfigControllerProvider.notifier)
        .updateConfig(config);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '✓ Delivery settings saved successfully'
              : 'Save failed: ${ref.read(adminDeliveryConfigControllerProvider).error}',
        ),
        backgroundColor: success ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(deliveryConfigProvider);
    final isSaving = ref.watch(adminDeliveryConfigControllerProvider).isLoading;

    if (!_seeded) {
      final config = configAsync.valueOrNull;
      if (config != null) _seedFrom(config);
    }

    return configAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(18.0),
        child: ErrorStateWidget(
          message: 'Couldn\'t load delivery settings: $e',
          onRetry: () => ref.invalidate(deliveryConfigProvider),
        ),
      ),
      data: (_) => SingleChildScrollView(
        padding: const EdgeInsets.all(18.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Warehouse Location',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Every delivery charge is calculated as straight-line distance from this point.',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _latController,
                            enabled: !isSaving,
                            decoration: const InputDecoration(labelText: 'Latitude'),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            validator: _validateCoordinate,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _lngController,
                            enabled: !isSaving,
                            decoration: const InputDecoration(labelText: 'Longitude'),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            validator: _validateCoordinate,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: (isSaving || _isLocating)
                            ? null
                            : _useCurrentLocation,
                        icon: _isLocating
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.my_location_rounded, size: 16),
                        label: const Text('Use current location'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Per-km Rate',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _rateController,
                      enabled: !isSaving,
                      decoration: const InputDecoration(
                        labelText: 'Rate (₹ per km)',
                        prefixText: '₹ ',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) {
                        final parsed = double.tryParse(v?.trim() ?? '');
                        if (parsed == null) return 'Enter a valid rate';
                        if (parsed <= 0) return 'Rate must be above ₹0';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Save Changes',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
