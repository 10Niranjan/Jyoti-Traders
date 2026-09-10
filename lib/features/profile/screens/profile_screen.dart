import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/geocoding_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/theme/locale_controller.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/address_entity.dart';
import '../../../domain/entities/bank_details_entity.dart';
import '../../../domain/entities/business_hours_entity.dart';
import '../../../domain/entities/notification_preferences_entity.dart';
import '../../../domain/entities/order_entity.dart';
import '../../../shared/widgets/address_form_fields.dart';
import '../../../shared/widgets/edit_basic_info_sheet.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/controllers/auth_state.dart';
import '../../orders/controllers/order_controller.dart';
import '../../../data/models/user_model.dart';
import '../controllers/profile_controller.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final _formKey = GlobalKey<FormState>();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _gstController = TextEditingController();
  final _accountHolderController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _upiController = TextEditingController();
  bool _prefilled = false;
  bool _saveSuccess = false;
  double? _latitude;
  double? _longitude;
  String? _resolvedAddress;
  bool _isLocating = false;

  bool _is24x7 = false;
  String _openTime = BusinessHoursEntity.defaults.openTime;
  String _closeTime = BusinessHoursEntity.defaults.closeTime;

  bool _orderUpdates = true;
  bool _promotions = true;
  bool _lowStockAlerts = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _gstController.dispose();
    _accountHolderController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    _bankNameController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  void _prefill(AuthenticatedCustomer state) {
    if (_prefilled) return;
    final user = state.user;
    final address = user.address;
    if (address != null) {
      _streetController.text = address.street;
      _cityController.text = address.city;
      _pincodeController.text = address.pincode;
      _latitude = address.latitude;
      _longitude = address.longitude;
      _resolvedAddress = address.formattedAddress;
    }
    _gstController.text = user.gstNumber ?? '';

    final bank = user.bankDetails;
    if (bank != null) {
      _accountHolderController.text = bank.accountHolderName;
      _accountNumberController.text = bank.accountNumber;
      _ifscController.text = bank.ifscCode;
      _bankNameController.text = bank.bankName;
      _upiController.text = bank.upiId ?? '';
    }

    final hours = user.businessHours;
    _is24x7 = hours?.is24x7 ?? false;
    _openTime = hours?.openTime ?? BusinessHoursEntity.defaults.openTime;
    _closeTime = hours?.closeTime ?? BusinessHoursEntity.defaults.closeTime;

    _orderUpdates = user.notificationPreferences.orderUpdates;
    _promotions = user.notificationPreferences.promotions;
    _lowStockAlerts = user.notificationPreferences.lowStockAlerts;

    _prefilled = true;
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isLocating = true);
    final position = await ref
        .read(locationServiceProvider)
        .getCurrentPosition();
    if (position == null) {
      if (mounted) {
        setState(() => _isLocating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.checkoutLocationError),
            backgroundColor: AppColors.error,
          ),
        );
      }
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
      _latitude = position.latitude;
      _longitude = position.longitude;
      if (resolved != null) {
        _resolvedAddress = resolved.formattedAddress;
        if (_streetController.text.trim().isEmpty && resolved.street != null) {
          _streetController.text = resolved.street!;
        }
        if (_cityController.text.trim().isEmpty && resolved.city != null) {
          _cityController.text = resolved.city!;
        }
        if (_pincodeController.text.trim().isEmpty &&
            resolved.pincode != null) {
          _pincodeController.text = resolved.pincode!;
        }
      }
    });
  }

  Future<void> _pickProfilePhoto(String uid) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;
      await ref
          .read(profileControllerProvider.notifier)
          .updatePhoto(uid: uid, localFilePath: picked.path);
      if (!mounted) return;
      final result = ref.read(profileControllerProvider);
      if (result.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              )!.profileUpdatePhotoError(result.error.toString()),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.upiGalleryError(e.toString()),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  TimeOfDay _parseTime(String hhmm) {
    final parts = hhmm.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTimeOfDay(String hhmm) {
    final t = _parseTime(hhmm);
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    final hour12 = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    return '${hour12.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} $period';
  }

  Future<void> _pickTime(bool isOpen) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _parseTime(isOpen ? _openTime : _closeTime),
    );
    if (picked == null) return;
    final formatted =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    setState(() {
      if (isOpen) {
        _openTime = formatted;
      } else {
        _closeTime = formatted;
      }
    });
  }

  Future<void> _save(String uid) async {
    if (!_formKey.currentState!.validate()) return;

    final hasBankInput =
        _accountHolderController.text.trim().isNotEmpty ||
        _accountNumberController.text.trim().isNotEmpty ||
        _ifscController.text.trim().isNotEmpty ||
        _bankNameController.text.trim().isNotEmpty ||
        _upiController.text.trim().isNotEmpty;

    await ref
        .read(profileControllerProvider.notifier)
        .updateProfile(
          uid: uid,
          address: AddressEntity(
            street: _streetController.text.trim(),
            city: _cityController.text.trim(),
            pincode: _pincodeController.text.trim(),
            latitude: _latitude,
            longitude: _longitude,
            formattedAddress: _resolvedAddress,
          ),
          gstNumber: _gstController.text.trim().isEmpty
              ? null
              : _gstController.text.trim(),
          bankDetails: hasBankInput
              ? BankDetailsEntity(
                  accountHolderName: _accountHolderController.text.trim(),
                  accountNumber: _accountNumberController.text.trim(),
                  ifscCode: _ifscController.text.trim().toUpperCase(),
                  bankName: _bankNameController.text.trim(),
                  upiId: _upiController.text.trim().isEmpty
                      ? null
                      : _upiController.text.trim(),
                )
              : null,
          businessHours: BusinessHoursEntity(
            openTime: _openTime,
            closeTime: _closeTime,
            is24x7: _is24x7,
          ),
        );
    if (!mounted) return;
    final result = ref.read(profileControllerProvider);
    if (result.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(
              context,
            )!.profileUpdateFailed(result.error.toString()),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    // Morph save button → green checkmark for 1.8 s, then revert.
    setState(() => _saveSuccess = true);
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _saveSuccess = false);
    });
  }

  Future<void> _saveNotificationPreferences(String uid) async {
    await ref
        .read(profileControllerProvider.notifier)
        .updateProfile(
          uid: uid,
          notificationPreferences: NotificationPreferencesEntity(
            orderUpdates: _orderUpdates,
            promotions: _promotions,
            lowStockAlerts: _lowStockAlerts,
          ),
        );
    if (!mounted) return;
    final result = ref.read(profileControllerProvider);
    if (result.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(
              context,
            )!.profileSaveFailed(result.error.toString()),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _confirmChangePassword(String email) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          l10n.profileChangePasswordDialogTitle,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        content: Text(
          l10n.profileResetLinkMessage(email),
          style: GoogleFonts.inter(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.profileSendLink),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref.read(profileControllerProvider.notifier).sendPasswordReset(email);
    if (!mounted) return;
    final result = ref.read(profileControllerProvider);
    if (result.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.profileResetLinkFailed(result.error.toString())),
          backgroundColor: AppColors.error,
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.profileResetLinkSent(email))));
    }
  }

  Future<void> _confirmRemoveAddress(
    String uid,
    List<AddressEntity> savedAddresses,
    AddressEntity address,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final label = address.label?.isNotEmpty == true
        ? address.label!
        : address.street;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          l10n.profileRemoveAddressTitle,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        content: Text(
          l10n.profileRemoveAddressContent(label),
          style: GoogleFonts.inter(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n.profileRemoveAddressAction,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref
        .read(profileControllerProvider.notifier)
        .updateProfile(
          uid: uid,
          savedAddresses: savedAddresses
              .where((a) => a.id != address.id)
              .toList(),
        );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.profileAddressRemoved)));
  }

  Future<void> _confirmLogout() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          l10n.profileLogoutDialogTitle,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        content: Text(
          l10n.profileLogoutDialogContent,
          style: GoogleFonts.inter(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n.profileLogOut,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      ref.read(authControllerProvider.notifier).signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final profileState = ref.watch(profileControllerProvider);

    if (authState is! AuthenticatedCustomer) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    _prefill(authState);
    final user = authState.user;
    final unselectedColor = Theme.of(
      context,
    ).colorScheme.onSurface.withOpacity(0.6);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.navProfile,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: unselectedColor,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(
              icon: const Icon(Icons.storefront_outlined),
              text: l10n.navProfile,
            ),
            Tab(
              icon: const Icon(Icons.settings_outlined),
              text: l10n.profileSettingsTab,
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProfileTab(user, profileState),
          _buildSettingsTab(user),
        ],
      ),
    );
  }

  Widget _buildProfileTab(UserModel user, AsyncValue<void> profileState) {
    final l10n = AppLocalizations.of(context)!;
    final orders = ref.watch(orderHistoryProvider).valueOrNull ?? const <OrderEntity>[];
    int idx = 0;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Bento stat-strip header ────────────────────────────────────
          _RetailerProfileHeader(
            user: user,
            orders: orders,
            isUploadingPhoto: profileState.isLoading,
            onEdit: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) => EditBasicInfoSheet(user: user),
            ),
            onTapPhoto: () => _pickProfilePhoto(user.uid),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: -0.05, end: 0, duration: 360.ms, curve: Curves.easeOutCubic),
          const SizedBox(height: 24),

          // ── Delivery Address ───────────────────────────────────────────
          _AnimatedSection(
            index: idx++,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionLabel(l10n.checkoutDeliveryAddress),
                _CardBody(
                  child: AddressFormFields(
                    streetController: _streetController,
                    cityController: _cityController,
                    pincodeController: _pincodeController,
                    resolvedAddress: _resolvedAddress,
                    isLocating: _isLocating,
                    onUseCurrentLocation: _useCurrentLocation,
                  ),
                ),
              ],
            ),
          ),

          // ── Saved Addresses ────────────────────────────────────────────
          if (user.savedAddresses.isNotEmpty) ...[
            const SizedBox(height: 16),
            _AnimatedSection(
              index: idx++,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel(l10n.profileSavedAddresses),
                  _CardBody(
                    child: Column(
                      children: [
                        for (final address in user.savedAddresses)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(
                              Icons.place_outlined,
                              color: AppColors.primary,
                            ),
                            title: Text(
                              address.label?.isNotEmpty == true
                                  ? address.label!
                                  : address.street,
                              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              '${address.street}, ${address.city} ${address.pincode}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppColors.error,
                              ),
                              tooltip: l10n.profileRemoveAddressAction,
                              onPressed: () => _confirmRemoveAddress(
                                user.uid,
                                user.savedAddresses,
                                address,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
          // ── Business Details ───────────────────────────────────────────
          _AnimatedSection(
            index: idx++,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionLabel(l10n.profileBusinessDetails),
                _CardBody(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _gstController,
                        decoration: InputDecoration(labelText: l10n.profileGstNumber),
                        textCapitalization: TextCapitalization.characters,
                        validator: Validators.gstNumber,
                      ),
                      const SizedBox(height: 16),
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
                                onPressed: () => _pickTime(true),
                                child: Text(
                                  l10n.profileOpensAt(_formatTimeOfDay(_openTime)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _pickTime(false),
                                child: Text(
                                  l10n.profileClosesAt(_formatTimeOfDay(_closeTime)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          // ── Payout Details ─────────────────────────────────────────────
          _AnimatedSection(
            index: idx++,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionLabel(l10n.profilePayoutDetails),
                _CardBody(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _accountHolderController,
                        decoration: InputDecoration(
                          labelText: l10n.profileAccountHolderName,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _accountNumberController,
                        decoration: InputDecoration(
                          labelText: l10n.profileAccountNumber,
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: Validators.bankAccountNumber,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _ifscController,
                        decoration: InputDecoration(labelText: l10n.profileIfscCode),
                        textCapitalization: TextCapitalization.characters,
                        validator: Validators.ifscCode,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _bankNameController,
                        decoration: InputDecoration(labelText: l10n.profileBankName),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _upiController,
                        decoration: InputDecoration(
                          labelText: l10n.profileUpiIdOptional,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          // ── Morphing save button ───────────────────────────────────────
          _AnimatedSection(
            index: idx,
            child: _MorphSaveButton(
              saveSuccess: _saveSuccess,
              isLoading: profileState.isLoading,
              onPressed: () => _save(user.uid),
              saveLabel: l10n.profileSaveChanges,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSettingsTab(UserModel user) {
    final l10n = AppLocalizations.of(context)!;
    int idx = 0;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Notifications ──────────────────────────────────────────────
        _AnimatedSection(
          index: idx++,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionLabel(l10n.profileNotifications),
              _CardBody(
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.profileOrderUpdates),
                      subtitle: Text(l10n.profileOrderUpdatesSubtitle),
                      value: _orderUpdates,
                      onChanged: (v) {
                        setState(() => _orderUpdates = v);
                        _saveNotificationPreferences(user.uid);
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.profilePromotions),
                      subtitle: Text(l10n.profilePromotionsSubtitle),
                      value: _promotions,
                      onChanged: (v) {
                        setState(() => _promotions = v);
                        _saveNotificationPreferences(user.uid);
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.profileLowStockAlerts),
                      subtitle: Text(l10n.profileLowStockAlertsSubtitle),
                      value: _lowStockAlerts,
                      onChanged: (v) {
                        setState(() => _lowStockAlerts = v);
                        _saveNotificationPreferences(user.uid);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // ── Appearance ─────────────────────────────────────────────────
        _AnimatedSection(
          index: idx++,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionLabel(l10n.profileAppearance),
              _CardBody(
                child: SegmentedButton<ThemeMode>(
                  segments: [
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text(l10n.themeSystem),
                      icon: const Icon(Icons.brightness_auto_outlined),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text(l10n.themeLight),
                      icon: const Icon(Icons.light_mode_outlined),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text(l10n.themeDark),
                      icon: const Icon(Icons.dark_mode_outlined),
                    ),
                  ],
                  selected: {ref.watch(themeModeProvider)},
                  onSelectionChanged: (selection) => ref
                      .read(themeModeProvider.notifier)
                      .setThemeMode(selection.first),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // ── Language ───────────────────────────────────────────────────
        _AnimatedSection(
          index: idx++,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionLabel(l10n.profileLanguage),
              _CardBody(
                child: SegmentedButton<Locale?>(
                  segments: [
                    ButtonSegment(value: null, label: Text(l10n.languageEnglish)),
                    ButtonSegment(
                      value: const Locale('hi'),
                      label: Text(l10n.languageHindi),
                    ),
                    ButtonSegment(
                      value: const Locale('mr'),
                      label: Text(l10n.languageMarathi),
                    ),
                  ],
                  selected: {ref.watch(localeProvider)},
                  onSelectionChanged: (selection) =>
                      ref.read(localeProvider.notifier).setLocale(selection.first),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // ── Account ────────────────────────────────────────────────────
        _AnimatedSection(
          index: idx++,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionLabel(l10n.profileAccountSection),
              _CardBody(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.password_outlined, color: AppColors.primary),
                  title: Text(l10n.profileChangePassword),
                  subtitle: Text(user.email),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _confirmChangePassword(user.email),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // ── Support ────────────────────────────────────────────────────
        _AnimatedSection(
          index: idx++,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionLabel(l10n.profileSupport),
              _CardBody(
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.call_outlined, color: AppColors.primary),
                      title: Text(l10n.profileCallSupport),
                      subtitle: const Text(AppConstants.kSupportPhone),
                      onTap: () => launchUrl(
                        Uri(scheme: 'tel', path: AppConstants.kSupportPhone),
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.email_outlined, color: AppColors.primary),
                      title: Text(l10n.profileEmailSupport),
                      subtitle: const Text(AppConstants.kSupportEmail),
                      onTap: () => launchUrl(
                        Uri(scheme: 'mailto', path: AppConstants.kSupportEmail),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // ── Log out ────────────────────────────────────────────────────
        _AnimatedSection(
          index: idx,
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _confirmLogout,
              icon: const Icon(Icons.logout_rounded, color: AppColors.error),
              label: Text(
                l10n.profileLogOut,
                style: const TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Profile Screen — private widgets ──────────────────────────────────────
// All widgets below are intentionally private to this file. Zero changes to
// any shared component (SectionCard, ProfileHeaderCard, PrimaryButton, etc.).

/// Wraps any widget in a per-index staggered fade + slide entrance via
/// [flutter_animate]. Each card enters with an 80 ms base delay + 70 ms per
/// index, producing the GSAP-timeline cascade requested.
class _AnimatedSection extends StatelessWidget {
  final int index;
  final Widget child;

  const _AnimatedSection({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: Duration(milliseconds: 80 + index * 70))
        .fadeIn(duration: const Duration(milliseconds: 350), curve: Curves.easeOut)
        .slideY(
          begin: 0.08,
          end: 0,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
        );
  }
}

/// Bold section heading with a 3 px primary-colour left-rule accent bar.
/// Rendered above each card rather than inside it — the "Vengeance UI" treatment:
/// heavier typography, clear visual hierarchy, breaks the wall-of-identical-cards.
class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 22,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

/// Lightweight card shell identical in visuals to [SectionCard] but without
/// the internal icon+title header row — so [_SectionLabel] can act as the
/// external heading without double-rendering the section name inside the card.
class _CardBody extends StatelessWidget {
  final Widget child;

  const _CardBody({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    );
  }
}

/// One dense info pill inside the bento stat strip.
class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatPill({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white.withOpacity(0.70)),
          const SizedBox(height: 5),
          Text(
            value,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.60),
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bento-style retailer profile header.
///
/// Replaces [ProfileHeaderCard] at the [_ProfileScreenState._buildProfileTab]
/// call site only. Admin screens continue using [ProfileHeaderCard] unchanged.
///
/// Visual breakdown:
/// - Dark [AppColors.primaryDark] rounded-rect card.
/// - Soft radial gradient glow behind the avatar (cheap depth, no 3D assets).
/// - Avatar row: photo + business name/owner name/phone + edit icon.
/// - Bento stat strip: Orders Placed | Total Business | Member Since.
class _RetailerProfileHeader extends StatelessWidget {
  final UserModel user;
  final List<OrderEntity> orders;
  final bool isUploadingPhoto;
  final VoidCallback onEdit;
  final VoidCallback onTapPhoto;

  const _RetailerProfileHeader({
    required this.user,
    required this.orders,
    required this.isUploadingPhoto,
    required this.onEdit,
    required this.onTapPhoto,
  });

  /// Compact ₹ formatter: ₹1.2L / ₹12.5k / ₹750
  static String _formatSpend(double amount) {
    if (amount >= 100000) return '₹${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return '₹${(amount / 1000).toStringAsFixed(1)}k';
    return '₹${amount.toInt()}';
  }

  Widget _buildAvatarContent() {
    if (user.photoUrl == null || user.photoUrl!.isEmpty) {
      return Text(
        user.businessName.isNotEmpty ? user.businessName[0].toUpperCase() : 'J',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      );
    }
    return SizedBox(
      width: 60,
      height: 60,
      child: user.photoUrl!.startsWith('http')
          ? CachedNetworkImage(imageUrl: user.photoUrl!, fit: BoxFit.cover)
          : Image.file(File(user.photoUrl!), fit: BoxFit.cover),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final totalSpend = orders.fold<double>(0, (sum, o) => sum + o.grandTotal.amount);
    final memberSince = DateFormat('MMM yyyy').format(user.createdAt);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Radial glow — "Spline vibe": soft depth behind avatar, no 3D assets.
          Positioned(
            top: -35,
            left: -25,
            child: Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0x887C3AED), // primary @ ~53 %
                    Color(0x007C3AED), // fade to transparent
                  ],
                ),
              ),
            ),
          ),
          // Secondary glow accent (teal) top-right for depth variation.
          Positioned(
            top: -20,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0x440D9488), // accent @ ~27 %
                    Color(0x000D9488),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Avatar + name row ─────────────────────────────────
                Row(
                  children: [
                    GestureDetector(
                      onTap: isUploadingPhoto ? null : onTapPhoto,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.55),
                                  blurRadius: 22,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white.withOpacity(0.16),
                              child: ClipOval(
                                child: isUploadingPhoto
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : _buildAvatarContent(),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -2,
                            right: -2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryDark,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.businessName,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            user.name,
                            style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.80),
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 1),
                          Text(
                            user.phone,
                            style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.60),
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, color: Colors.white),
                      tooltip: l10n.editProfileTooltip,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // ── Bento stat strip ──────────────────────────────────
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                  ),
                  child: Row(
                    children: [
                      _StatPill(
                        label: 'Orders',
                        value: '${orders.length}',
                        icon: Icons.shopping_bag_outlined,
                      ),
                      Container(
                        width: 1,
                        height: 36,
                        color: Colors.white.withOpacity(0.15),
                      ),
                      _StatPill(
                        label: 'Business',
                        value: _formatSpend(totalSpend),
                        icon: Icons.currency_rupee_rounded,
                      ),
                      Container(
                        width: 1,
                        height: 36,
                        color: Colors.white.withOpacity(0.15),
                      ),
                      _StatPill(
                        label: 'Since',
                        value: memberSince,
                        icon: Icons.calendar_today_outlined,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Save button that morphs into a green "✓ Saved!" state for 1.8 s after a
/// successful profile save, then returns to the default via [AnimatedSwitcher].
/// Replaces [PrimaryButton] at the one profile-tab call site only.
class _MorphSaveButton extends StatelessWidget {
  final bool saveSuccess;
  final bool isLoading;
  final VoidCallback? onPressed;
  final String saveLabel;

  const _MorphSaveButton({
    required this.saveSuccess,
    required this.isLoading,
    required this.onPressed,
    required this.saveLabel,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: Tween<double>(begin: 0.93, end: 1.0).animate(animation),
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: saveSuccess
          ? SizedBox(
              key: const ValueKey('saved'),
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: null,
                icon: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                label: const Text(
                  'Saved!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  // Keep the green even while "disabled" (null onPressed).
                  disabledBackgroundColor: AppColors.success,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.92, 0.92),
                    end: const Offset(1.0, 1.0),
                    duration: const Duration(milliseconds: 420),
                    curve: Curves.elasticOut,
                  ),
            )
          : PrimaryButton(
              key: const ValueKey('save'),
              label: saveLabel,
              isLoading: isLoading,
              onPressed: onPressed,
            ),
    );
  }
}
