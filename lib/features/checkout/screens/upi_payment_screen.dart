import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/route_names.dart';
import '../../../core/utils/extensions.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../../shared/widgets/image_picker_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../orders/controllers/order_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../controllers/upi_payment_controller.dart';

/// Shown right after a UPI order is placed (PRD §7): QR + UPI ID to pay,
/// an optional payment-screenshot upload, and an "I have paid" button that
/// records the retailer's claim for the admin to manually confirm.
class UpiPaymentScreen extends ConsumerStatefulWidget {
  final String orderId;

  const UpiPaymentScreen({super.key, required this.orderId});

  @override
  ConsumerState<UpiPaymentScreen> createState() => _UpiPaymentScreenState();
}

class _UpiPaymentScreenState extends ConsumerState<UpiPaymentScreen> {
  String? _pickedScreenshotPath;

  Future<void> _pickScreenshot() async {
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1200, imageQuality: 80);
      if (picked != null && mounted) {
        setState(() => _pickedScreenshotPath = picked.path);
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

  void _copyUpiId() {
    Clipboard.setData(const ClipboardData(text: AppConstants.kUpiId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.upiIdCopied), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _confirmPayment() async {
    final success = await ref
        .read(upiPaymentControllerProvider.notifier)
        .confirmPayment(widget.orderId, localScreenshotPath: _pickedScreenshotPath);
    if (!mounted) return;

    if (success) {
      context.pushReplacement(RouteNames.orderSuccessPath(widget.orderId));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!
              .upiConfirmError(ref.read(upiPaymentControllerProvider).error.toString())),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(orderByIdProvider(widget.orderId));
    final isSaving = ref.watch(upiPaymentControllerProvider).isLoading;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.upiPaymentTitle, style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorStateWidget(message: l10n.upiOrderLoadError(e.toString())),
        data: (order) {
          if (order == null) {
            return ErrorStateWidget(message: l10n.upiOrderNotFound);
          }

          final upiLink = 'upi://pay'
              '?pa=${AppConstants.kUpiId}'
              '&pn=${Uri.encodeComponent(AppConstants.kUpiPayeeName)}'
              '&am=${order.grandTotal.amount.toStringAsFixed(2)}'
              '&cu=INR'
              '&tn=${Uri.encodeComponent('Order ${order.id.shortId}')}';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  l10n.upiPayAmount(order.grandTotal.formatted),
                  style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.upiScanInstructions,
                  style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.textSecondaryLight),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFA78BFA), width: 2),
                  ),
                  child: QrImageView(data: upiLink, size: 200, backgroundColor: Colors.white),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _copyUpiId,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(AppConstants.kUpiId, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(width: 8),
                        const Icon(Icons.copy_rounded, size: 16, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(l10n.upiScreenshotLabel, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 8),
                ImagePickerField(
                  pickedPath: _pickedScreenshotPath,
                  existingUrl: null,
                  onPick: isSaving ? null : _pickScreenshot,
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  label: l10n.upiIHavePaid,
                  icon: Icons.check_circle_outline_rounded,
                  isLoading: isSaving,
                  onPressed: _confirmPayment,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.upiConfirmationNote,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textSecondaryLight),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
