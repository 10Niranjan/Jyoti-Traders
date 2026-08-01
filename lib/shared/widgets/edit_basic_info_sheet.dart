import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../data/models/user_model.dart';
import '../../features/profile/controllers/profile_controller.dart';
import 'primary_button.dart';

/// Bottom sheet for the identity fields (name/phone/[shop name]) — reuses
/// the exact validators and input formatters the sign-up form enforces, so
/// "letters only", "10 digits", etc. stay consistent everywhere a user can
/// type this data. Shared by the retailer and admin profile screens;
/// [showShopName] is off for admin, which has no shop to name.
class EditBasicInfoSheet extends StatefulWidget {
  final UserModel user;
  final bool showShopName;

  const EditBasicInfoSheet({super.key, required this.user, this.showShopName = true});

  @override
  State<EditBasicInfoSheet> createState() => _EditBasicInfoSheetState();
}

class _EditBasicInfoSheetState extends State<EditBasicInfoSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.user.name);
  late final _phoneController = TextEditingController(text: widget.user.phone);
  late final _shopController = TextEditingController(text: widget.user.businessName);

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _shopController.dispose();
    super.dispose();
  }

  Future<void> _save(WidgetRef ref) async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(profileControllerProvider.notifier).updateProfile(
          uid: widget.user.uid,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          businessName: widget.showShopName ? _shopController.text.trim() : null,
        );
    if (!mounted) return;
    final result = ref.read(profileControllerProvider);
    if (result.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: ${result.error}'), backgroundColor: AppColors.error),
      );
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final isSaving = ref.watch(profileControllerProvider).isLoading;
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Edit Profile', style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full Name', helperText: 'Letters and spaces only'),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: Validators.name,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp("[a-zA-Z' -]")),
                    LengthLimitingTextInputFormatter(50),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number', helperText: '10-digit mobile number'),
                  keyboardType: TextInputType.phone,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: Validators.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                ),
                if (widget.showShopName) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _shopController,
                    decoration: const InputDecoration(labelText: 'Business / Shop Name'),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: Validators.businessName,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9 &.-]')),
                      LengthLimitingTextInputFormatter(100),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Save',
                  isLoading: isSaving,
                  onPressed: () => _save(ref),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
