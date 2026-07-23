import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';

/// Street/city/pincode fields plus a "use current location" row — shared by
/// `ProfileScreen` and `CheckoutScreen`, which previously duplicated the
/// same three `TextFormField`s. Capturing GPS coordinates here is what lets
/// checkout calculate a real per-km delivery charge instead of the flat
/// placeholder (phases.md §5).
class AddressFormFields extends StatelessWidget {
  final TextEditingController streetController;
  final TextEditingController cityController;
  final TextEditingController pincodeController;
  final bool hasCoordinates;
  final bool isLocating;
  final VoidCallback onUseCurrentLocation;

  const AddressFormFields({
    super.key,
    required this.streetController,
    required this.cityController,
    required this.pincodeController,
    required this.hasCoordinates,
    required this.isLocating,
    required this.onUseCurrentLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: streetController,
          decoration: const InputDecoration(labelText: 'Street / Shop Address'),
          validator: Validators.address,
        ),
        TextFormField(
          controller: cityController,
          decoration: const InputDecoration(labelText: 'City'),
          validator: (v) => Validators.required(v, fieldName: 'City'),
        ),
        TextFormField(
          controller: pincodeController,
          decoration: const InputDecoration(labelText: 'Pincode'),
          keyboardType: TextInputType.number,
          validator: (v) => Validators.required(v, fieldName: 'Pincode'),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              hasCoordinates ? Icons.check_circle : Icons.location_off_outlined,
              size: 16,
              color: hasCoordinates ? AppColors.success : AppColors.textSecondaryLight,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                hasCoordinates
                    ? 'Location saved — used for accurate delivery pricing'
                    : 'Add your location for accurate delivery pricing',
                style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textSecondaryLight),
              ),
            ),
            TextButton.icon(
              onPressed: isLocating ? null : onUseCurrentLocation,
              icon: isLocating
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.my_location_rounded, size: 16),
              label: Text(hasCoordinates ? 'Update' : 'Use current location'),
            ),
          ],
        ),
      ],
    );
  }
}
