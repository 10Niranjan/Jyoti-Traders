import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/geocoding_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/address_entity.dart';
import '../../../domain/entities/bank_details_entity.dart';
import '../../../domain/entities/business_hours_entity.dart';
import '../../../domain/entities/notification_preferences_entity.dart';
import '../../../shared/widgets/address_form_fields.dart';
import '../../../shared/widgets/edit_basic_info_sheet.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/profile_header_card.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../core/theme/locale_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/controllers/auth_state.dart';
import '../controllers/profile_controller.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with SingleTickerProviderStateMixin {
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
    final position = await ref.read(locationServiceProvider).getCurrentPosition();
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
        .reverseGeocode(latitude: position.latitude, longitude: position.longitude);
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
        if (_pincodeController.text.trim().isEmpty && resolved.pincode != null) {
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
      await ref.read(profileControllerProvider.notifier).updatePhoto(uid: uid, localFilePath: picked.path);
      if (!mounted) return;
      final result = ref.read(profileControllerProvider);
      if (result.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.profileUpdatePhotoError(result.error.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.upiGalleryError(e.toString())),
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
    final formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
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

    final hasBankInput = _accountHolderController.text.trim().isNotEmpty ||
        _accountNumberController.text.trim().isNotEmpty ||
        _ifscController.text.trim().isNotEmpty ||
        _bankNameController.text.trim().isNotEmpty ||
        _upiController.text.trim().isNotEmpty;

    await ref.read(profileControllerProvider.notifier).updateProfile(
          uid: uid,
          address: AddressEntity(
            street: _streetController.text.trim(),
            city: _cityController.text.trim(),
            pincode: _pincodeController.text.trim(),
            latitude: _latitude,
            longitude: _longitude,
            formattedAddress: _resolvedAddress,
          ),
          gstNumber: _gstController.text.trim().isEmpty ? null : _gstController.text.trim(),
          bankDetails: hasBankInput
              ? BankDetailsEntity(
                  accountHolderName: _accountHolderController.text.trim(),
                  accountNumber: _accountNumberController.text.trim(),
                  ifscCode: _ifscController.text.trim().toUpperCase(),
                  bankName: _bankNameController.text.trim(),
                  upiId: _upiController.text.trim().isEmpty ? null : _upiController.text.trim(),
                )
              : null,
          businessHours: BusinessHoursEntity(openTime: _openTime, closeTime: _closeTime, is24x7: _is24x7),
        );
    if (!mounted) return;
    final result = ref.read(profileControllerProvider);
    if (result.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.profileUpdateFailed(result.error.toString())),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.profileUpdated)));
  }

  Future<void> _saveNotificationPreferences(String uid) async {
    await ref.read(profileControllerProvider.notifier).updateProfile(
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
          content: Text(AppLocalizations.of(context)!.profileSaveFailed(result.error.toString())),
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
        title: Text(l10n.profileChangePasswordDialogTitle, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 17)),
        content: Text(
          l10n.profileResetLinkMessage(email),
          style: GoogleFonts.inter(fontSize: 13),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(l10n.cancelButton)),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text(l10n.profileSendLink)),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileResetLinkSent(email))),
      );
    }
  }

  Future<void> _confirmLogout() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.profileLogoutDialogTitle, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 17)),
        content: Text(
          l10n.profileLogoutDialogContent,
          style: GoogleFonts.inter(fontSize: 13),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(l10n.cancelButton)),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.profileLogOut, style: const TextStyle(color: AppColors.error)),
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
    final unselectedColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navProfile, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: unselectedColor,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(icon: const Icon(Icons.storefront_outlined), text: l10n.navProfile),
            Tab(icon: const Icon(Icons.settings_outlined), text: l10n.profileSettingsTab),
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

  Widget _buildProfileTab(dynamic user, AsyncValue<void> profileState) {
    final l10n = AppLocalizations.of(context)!;
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ProfileHeaderCard(
            title: user.businessName,
            subtitleLines: [user.name, user.phone],
            photoUrl: user.photoUrl,
            isUploadingPhoto: profileState.isLoading,
            onEdit: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
              builder: (_) => EditBasicInfoSheet(user: user),
            ),
            onTapPhoto: () => _pickProfilePhoto(user.uid),
          ),
          const SizedBox(height: 20),
          SectionCard(
            title: l10n.checkoutDeliveryAddress,
            icon: Icons.location_on_outlined,
            child: AddressFormFields(
              streetController: _streetController,
              cityController: _cityController,
              pincodeController: _pincodeController,
              resolvedAddress: _resolvedAddress,
              isLocating: _isLocating,
              onUseCurrentLocation: _useCurrentLocation,
            ),
          ),
          SectionCard(
            title: l10n.profileBusinessDetails,
            icon: Icons.storefront_outlined,
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
                          child: Text(l10n.profileOpensAt(_formatTimeOfDay(_openTime))),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _pickTime(false),
                          child: Text(l10n.profileClosesAt(_formatTimeOfDay(_closeTime))),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          SectionCard(
            title: l10n.profilePayoutDetails,
            icon: Icons.account_balance_outlined,
            child: Column(
              children: [
                TextFormField(
                  controller: _accountHolderController,
                  decoration: InputDecoration(labelText: l10n.profileAccountHolderName),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _accountNumberController,
                  decoration: InputDecoration(labelText: l10n.profileAccountNumber),
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
                  decoration: InputDecoration(labelText: l10n.profileUpiIdOptional),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          PrimaryButton(
            label: l10n.profileSaveChanges,
            isLoading: profileState.isLoading,
            onPressed: () => _save(user.uid),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSettingsTab(dynamic user) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionCard(
          title: l10n.profileNotifications,
          icon: Icons.notifications_outlined,
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
        SectionCard(
          title: l10n.profileAppearance,
          icon: Icons.palette_outlined,
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
            onSelectionChanged: (selection) =>
                ref.read(themeModeProvider.notifier).setThemeMode(selection.first),
          ),
        ),
        SectionCard(
          title: l10n.profileLanguage,
          icon: Icons.language_outlined,
          child: SegmentedButton<Locale?>(
            segments: [
              ButtonSegment(value: null, label: Text(l10n.languageEnglish)),
              ButtonSegment(value: const Locale('hi'), label: Text(l10n.languageHindi)),
              ButtonSegment(value: const Locale('mr'), label: Text(l10n.languageMarathi)),
            ],
            selected: {ref.watch(localeProvider)},
            onSelectionChanged: (selection) =>
                ref.read(localeProvider.notifier).setLocale(selection.first),
          ),
        ),
        SectionCard(
          title: l10n.profileAccountSection,
          icon: Icons.lock_outline,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.password_outlined, color: AppColors.primary),
            title: Text(l10n.profileChangePassword),
            subtitle: Text(user.email),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _confirmChangePassword(user.email),
          ),
        ),
        SectionCard(
          title: l10n.profileSupport,
          icon: Icons.support_agent_outlined,
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.call_outlined, color: AppColors.primary),
                title: Text(l10n.profileCallSupport),
                subtitle: const Text(AppConstants.kSupportPhone),
                onTap: () => launchUrl(Uri(scheme: 'tel', path: AppConstants.kSupportPhone)),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.email_outlined, color: AppColors.primary),
                title: Text(l10n.profileEmailSupport),
                subtitle: const Text(AppConstants.kSupportEmail),
                onTap: () => launchUrl(Uri(scheme: 'mailto', path: AppConstants.kSupportEmail)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _confirmLogout,
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            label: Text(l10n.profileLogOut, style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
