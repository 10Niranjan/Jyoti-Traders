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
import '../../auth/controllers/auth_controller.dart';
import '../../auth/controllers/auth_state.dart';
import '../controllers/profile_controller.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
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
  void dispose() {
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
          const SnackBar(
            content: Text('Couldn\'t get your location. Check location permission and try again.'),
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
          SnackBar(content: Text('Couldn\'t update photo: ${result.error}'), backgroundColor: AppColors.error),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Couldn\'t open the gallery: $e'), backgroundColor: AppColors.error),
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
        SnackBar(content: Text('Update failed: ${result.error}'), backgroundColor: AppColors.error),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Log out?', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 17)),
        content: Text(
          'You\'ll need to sign in again to access your account.',
          style: GoogleFonts.inter(fontSize: 13),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Log Out', style: TextStyle(color: AppColors.error)),
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

    return Scaffold(
      appBar: AppBar(title: Text('Profile', style: GoogleFonts.poppins(fontWeight: FontWeight.bold))),
      body: Form(
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
              title: 'Delivery Address',
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
              title: 'Business Details',
              icon: Icons.storefront_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _gstController,
                    decoration: const InputDecoration(labelText: 'GST Number (optional)'),
                    textCapitalization: TextCapitalization.characters,
                    validator: Validators.gstNumber,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Open 24x7'),
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
                            child: Text('Opens: ${_formatTimeOfDay(_openTime)}'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _pickTime(false),
                            child: Text('Closes: ${_formatTimeOfDay(_closeTime)}'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            SectionCard(
              title: 'Payout Details',
              icon: Icons.account_balance_outlined,
              child: Column(
                children: [
                  TextFormField(
                    controller: _accountHolderController,
                    decoration: const InputDecoration(labelText: 'Account Holder Name'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _accountNumberController,
                    decoration: const InputDecoration(labelText: 'Account Number'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: Validators.bankAccountNumber,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _ifscController,
                    decoration: const InputDecoration(labelText: 'IFSC Code'),
                    textCapitalization: TextCapitalization.characters,
                    validator: Validators.ifscCode,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _bankNameController,
                    decoration: const InputDecoration(labelText: 'Bank Name'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _upiController,
                    decoration: const InputDecoration(labelText: 'UPI ID (optional)'),
                  ),
                ],
              ),
            ),
            SectionCard(
              title: 'Notifications',
              icon: Icons.notifications_outlined,
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Order Updates'),
                    subtitle: const Text('Status changes for your orders'),
                    value: _orderUpdates,
                    onChanged: (v) => setState(() => _orderUpdates = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Promotions'),
                    subtitle: const Text('Offers and discounts'),
                    value: _promotions,
                    onChanged: (v) => setState(() => _promotions = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Low Stock Alerts'),
                    subtitle: const Text('When items you buy often are running low'),
                    value: _lowStockAlerts,
                    onChanged: (v) => setState(() => _lowStockAlerts = v),
                  ),
                ],
              ),
            ),
            PrimaryButton(
              label: 'Save Changes',
              isLoading: profileState.isLoading,
              onPressed: () => _save(user.uid),
            ),
            const SizedBox(height: 24),
            SectionCard(
              title: 'Support',
              icon: Icons.support_agent_outlined,
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.call_outlined, color: AppColors.primary),
                    title: const Text('Call Support'),
                    subtitle: const Text(AppConstants.kSupportPhone),
                    onTap: () => launchUrl(Uri(scheme: 'tel', path: AppConstants.kSupportPhone)),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.email_outlined, color: AppColors.primary),
                    title: const Text('Email Support'),
                    subtitle: const Text(AppConstants.kSupportEmail),
                    onTap: () => launchUrl(Uri(scheme: 'mailto', path: AppConstants.kSupportEmail)),
                  ),
                ],
              ),
            ),
            SectionCard(
              title: 'Appearance',
              icon: Icons.palette_outlined,
              child: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text('System'),
                    icon: Icon(Icons.brightness_auto_outlined),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    label: Text('Light'),
                    icon: Icon(Icons.light_mode_outlined),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text('Dark'),
                    icon: Icon(Icons.dark_mode_outlined),
                  ),
                ],
                selected: {ref.watch(themeModeProvider)},
                onSelectionChanged: (selection) =>
                    ref.read(themeModeProvider.notifier).setThemeMode(selection.first),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _confirmLogout,
                icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                label: const Text('Log Out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
