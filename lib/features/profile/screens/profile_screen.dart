import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/address_entity.dart';
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
    }
    _gstController.text = state.user.gstNumber ?? '';
    _prefilled = true;
  }

  Future<void> _save(String uid) async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(profileControllerProvider.notifier).updateProfile(
          uid: uid,
          address: AddressEntity(
            street: _streetController.text.trim(),
            city: _cityController.text.trim(),
            pincode: _pincodeController.text.trim(),
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
            TextFormField(
              controller: _streetController,
              decoration: const InputDecoration(labelText: 'Street / Shop Address'),
              validator: Validators.address,
            ),
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(labelText: 'City'),
              validator: (v) => Validators.required(v, fieldName: 'City'),
            ),
            TextFormField(
              controller: _pincodeController,
              decoration: const InputDecoration(labelText: 'Pincode'),
              keyboardType: TextInputType.number,
              validator: (v) => Validators.required(v, fieldName: 'Pincode'),
            ),
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
          ],
        ),
      ),
    );
  }
}
