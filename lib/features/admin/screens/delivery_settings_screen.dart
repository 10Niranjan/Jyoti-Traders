import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/location_service.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../domain/entities/delivery_config_entity.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../../shared/widgets/staggered_entrance.dart';
import '../controllers/admin_delivery_config_controller.dart';
import '../widgets/delivery_form_parts.dart';
import '../widgets/delivery_pricing_hero.dart';
import '../widgets/delivery_sample_charges.dart';

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
///
/// Laid out as a scrolling column of cards above a pinned Save bar. The hero
/// and the "what retailers will pay" preview follow the rate field live, and
/// Save is only enabled once something has actually changed.
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

  // What the fields held when last loaded or saved — "dirty" is any
  // difference from these.
  String _baseLat = '';
  String _baseLng = '';
  String _baseRate = '';

  @override
  void initState() {
    super.initState();
    for (final c in [_latController, _lngController, _rateController]) {
      c.addListener(_onFieldChanged);
    }
  }

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  // Seeding happens during `build`, which sets the controllers' text — the
  // `_seeded` guard keeps that from calling `setState` mid-build.
  void _onFieldChanged() {
    if (_seeded && mounted) setState(() {});
  }

  bool get _dirty =>
      _latController.text.trim() != _baseLat ||
      _lngController.text.trim() != _baseLng ||
      _rateController.text.trim() != _baseRate;

  double? get _rate => double.tryParse(_rateController.text.trim());

  void _rememberBaseline() {
    _baseLat = _latController.text.trim();
    _baseLng = _lngController.text.trim();
    _baseRate = _rateController.text.trim();
  }

  void _seedFrom(DeliveryConfigEntity config) {
    _latController.text = config.warehouseLat.toString();
    _lngController.text = config.warehouseLng.toString();
    _rateController.text = config.perKmRate.toString();
    _rememberBaseline();
    _seeded = true;
  }

  void _setRate(num value) {
    _rateController.text = value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }

  void _bumpRate(int delta) {
    _setRate(((_rate ?? 0) + delta).clamp(1, 999));
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

    if (success) setState(_rememberBaseline);

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
      // Shrinks above the keyboard so the pinned Save bar is never covered.
      data: (_) => AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 6, 18, 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StaggeredEntrance(
                        index: 0,
                        child: DeliveryPricingHero(rate: _rate),
                      ),
                      const SizedBox(height: 20),
                      StaggeredEntrance(
                        index: 1,
                        child: DeliveryQuickRates(
                          current: _rate,
                          onPick: _setRate,
                        ),
                      ),
                      const SizedBox(height: 16),
                      StaggeredEntrance(
                        index: 2,
                        child: _rateCard(l10n, isSaving),
                      ),
                      const SizedBox(height: 16),
                      StaggeredEntrance(
                        index: 3,
                        child: DeliverySampleCharges(rate: _rate),
                      ),
                      const SizedBox(height: 16),
                      StaggeredEntrance(
                        index: 4,
                        child: _warehouseCard(l10n, isSaving),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            DeliverySaveBar(dirty: _dirty, isSaving: isSaving, onSave: _save),
          ],
        ),
      ),
    );
  }

  Widget _rateCard(AppLocalizations l10n, bool isSaving) {
    final rate = _rate;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: context.cardDecoration(radius: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DeliveryCardHeader(
            icon: Icons.payments_rounded,
            title: l10n.adminPerKmRate,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              DeliveryStepButton(
                icon: Icons.remove_rounded,
                tooltip: l10n.adminDeliveryRateDecrease,
                onPressed: isSaving || rate == null || rate <= 1
                    ? null
                    : () => _bumpRate(-1),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _rateController,
                  enabled: !isSaving,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: context.textPrimary,
                  ),
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
              ),
              const SizedBox(width: 12),
              DeliveryStepButton(
                icon: Icons.add_rounded,
                tooltip: l10n.adminDeliveryRateIncrease,
                onPressed: isSaving || (rate ?? 0) >= 999
                    ? null
                    : () => _bumpRate(1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _warehouseCard(AppLocalizations l10n, bool isSaving) {
    const coordinateKeyboard = TextInputType.numberWithOptions(
      decimal: true,
      signed: true,
    );
    final fieldStyle = GoogleFonts.inter(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: context.textPrimary,
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: context.cardDecoration(radius: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DeliveryCardHeader(
            icon: Icons.location_on_rounded,
            title: l10n.adminWarehouseLocation,
            subtitle: l10n.adminWarehouseLocationHint,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _latController,
                  enabled: !isSaving,
                  style: fieldStyle,
                  decoration: InputDecoration(labelText: l10n.adminLatitude),
                  keyboardType: coordinateKeyboard,
                  validator: _validateCoordinate,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _lngController,
                  enabled: !isSaving,
                  style: fieldStyle,
                  decoration: InputDecoration(labelText: l10n.adminLongitude),
                  keyboardType: coordinateKeyboard,
                  validator: _validateCoordinate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: (isSaving || _isLocating) ? null : _useCurrentLocation,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: _isLocating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location_rounded, size: 18),
              label: Text(l10n.adminUseCurrentLocation),
            ),
          ),
        ],
      ),
    );
  }
}
