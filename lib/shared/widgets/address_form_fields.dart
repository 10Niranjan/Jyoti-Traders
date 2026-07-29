import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';

/// Street/city/pincode fields plus a "use current location" row — shared by
/// `ProfileScreen` and `CheckoutScreen`, which previously duplicated the
/// same three `TextFormField`s. Capturing GPS coordinates here is what lets
/// checkout calculate a real per-km delivery charge instead of the flat
/// placeholder.
///
/// [resolvedAddress] is the human-readable line a reverse-geocode produced
/// from the last GPS fix — raw lat/lng is never surfaced to the retailer,
/// only this resolved text, so "did location capture work?" has a legible
/// answer instead of a bare checkmark.
class AddressFormFields extends StatelessWidget {
  final TextEditingController streetController;
  final TextEditingController cityController;
  final TextEditingController pincodeController;
  final String? resolvedAddress;
  final bool isLocating;
  final VoidCallback onUseCurrentLocation;

  const AddressFormFields({
    super.key,
    required this.streetController,
    required this.cityController,
    required this.pincodeController,
    required this.resolvedAddress,
    required this.isLocating,
    required this.onUseCurrentLocation,
  });

  @override
  Widget build(BuildContext context) {
    final hasResolvedAddress = resolvedAddress != null && resolvedAddress!.trim().isNotEmpty;
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
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              hasResolvedAddress ? Icons.check_circle : Icons.location_off_outlined,
              size: 16,
              color: hasResolvedAddress ? AppColors.success : AppColors.textSecondaryLight,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: isLocating
                  ? Text(
                      'Detecting your location…',
                      style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textSecondaryLight),
                    )
                  : hasResolvedAddress
                      ? Text.rich(
                          TextSpan(
                            style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textSecondaryLight),
                            children: [
                              const TextSpan(text: 'Detected: ', style: TextStyle(fontWeight: FontWeight.w600)),
                              TextSpan(text: resolvedAddress),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )
                      : Text(
                          'Add your location for accurate delivery pricing',
                          style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textSecondaryLight),
                        ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: isLocating ? null : onUseCurrentLocation,
            icon: isLocating
                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.my_location_rounded, size: 16),
            label: Text(hasResolvedAddress ? 'Refresh location' : 'Use current location'),
          ),
        ),
      ],
    );
  }
}
