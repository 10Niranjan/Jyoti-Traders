import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_shadows.dart';
import '../../../core/services/location_service.dart';
import '../../../domain/entities/delivery_config_entity.dart';
import '../../../l10n/app_localizations.dart';
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
          AppLocalizations.of(context)!.adminDeliverySettingsTitle,
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
        SnackBar(
          content: Text(AppLocalizations.of(context)!.checkoutLocationError),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  String? _validateCoordinate(String? v) {
    return double.tryParse(v?.trim() ?? '') == null
        ? AppLocalizations.of(context)!.adminEnterValidCoordinate
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
    final l10n = AppLocalizations.of(context)!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? l10n.adminDeliverySavedSuccess
              : l10n.adminSaveFailed(
                  '${ref.read(adminDeliveryConfigControllerProvider).error}',
                ),
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
    final l10n = AppLocalizations.of(context)!;

    if (!_seeded) {
      final config = configAsync.valueOrNull;
      if (config != null) _seedFrom(config);
    }

    return configAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(18.0),
        child: ErrorStateWidget(
          message: l10n.adminCouldntLoadDeliverySettings('$e'),
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
                  border: Border.all(color: AppColors.cardBorder),
                  boxShadow: AppShadows.card,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.adminWarehouseLocation,
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.adminWarehouseLocationHint,
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
                            decoration: InputDecoration(
                              labelText: l10n.adminLatitude,
                            ),
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
                            decoration: InputDecoration(
                              labelText: l10n.adminLongitude,
                            ),
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
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.my_location_rounded, size: 16),
                        label: Text(l10n.adminUseCurrentLocation),
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
                  border: Border.all(color: AppColors.cardBorder),
                  boxShadow: AppShadows.card,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.adminPerKmRate,
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _rateController,
                      enabled: !isSaving,
                      decoration: InputDecoration(
                        labelText: l10n.adminRateLabelPerKm,
                        prefixText: '₹ ',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) {
                        final parsed = double.tryParse(v?.trim() ?? '');
                        if (parsed == null) return l10n.adminEnterValidRate;
                        if (parsed <= 0) return l10n.adminRateMustBeAbove0;
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
                          l10n.adminSaveChanges,
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
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
