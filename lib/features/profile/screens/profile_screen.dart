import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/location_service.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/address_entity.dart';
import '../../../shared/widgets/address_form_fields.dart';
import '../../../shared/widgets/primary_button.dart';
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
  bool _prefilled = false;
  double? _latitude;
  double? _longitude;
  bool _isLocating = false;

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _gstController.dispose();
    super.dispose();
  }

  void _prefill(AuthenticatedCustomer state) {
    if (_prefilled) return;
    final address = state.user.address;
    if (address != null) {
      _streetController.text = address.street;
      _cityController.text = address.city;
      _pincodeController.text = address.pincode;
      _latitude = address.latitude;
      _longitude = address.longitude;
    }
    _gstController.text = state.user.gstNumber ?? '';
    _prefilled = true;
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isLocating = true);
    final position = await ref.read(locationServiceProvider).getCurrentPosition();
    if (!mounted) return;
    setState(() {
      _isLocating = false;
      if (position != null) {
        _latitude = position.latitude;
        _longitude = position.longitude;
      }
    });
    if (position == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Couldn\'t get your location. Check location permission and try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _save(String uid) async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(profileControllerProvider.notifier).updateProfile(
          uid: uid,
          address: AddressEntity(
            street: _streetController.text.trim(),
            city: _cityController.text.trim(),
            pincode: _pincodeController.text.trim(),
            latitude: _latitude,
            longitude: _longitude,
          ),
          gstNumber: _gstController.text.trim().isEmpty ? null : _gstController.text.trim(),
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
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
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(user.businessName, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Owner: ${user.name}', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondaryLight)),
            Text(user.phone, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondaryLight)),
            const SizedBox(height: 24),
            Text('Delivery Address', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            AddressFormFields(
              streetController: _streetController,
              cityController: _cityController,
              pincodeController: _pincodeController,
              hasCoordinates: _latitude != null && _longitude != null,
              isLocating: _isLocating,
              onUseCurrentLocation: _useCurrentLocation,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _gstController,
              decoration: const InputDecoration(labelText: 'GST Number (optional)'),
              textCapitalization: TextCapitalization.characters,
              validator: Validators.gstNumber,
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Save Changes',
              isLoading: profileState.isLoading,
              onPressed: () => _save(user.uid),
            ),
            const SizedBox(height: 32),
            Text('Support', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
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
            const SizedBox(height: 32),
            Text('Appearance', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            SegmentedButton<ThemeMode>(
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
          ],
        ),
      ),
    );
  }
}
