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
        SnackBar(content: Text('Couldn\'t open the gallery: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  void _copyUpiId() {
    Clipboard.setData(const ClipboardData(text: AppConstants.kUpiId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('UPI ID copied.'), behavior: SnackBarBehavior.floating),
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
          content: Text('Couldn\'t confirm payment: ${ref.read(upiPaymentControllerProvider).error}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(orderByIdProvider(widget.orderId));
    final isSaving = ref.watch(upiPaymentControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: Text('UPI Payment', style: GoogleFonts.poppins(fontWeight: FontWeight.bold))),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorStateWidget(message: 'Couldn\'t load order: $e'),
        data: (order) {
          if (order == null) {
            return const ErrorStateWidget(message: 'This order could not be found.');
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
                  'Pay ${order.grandTotal.formatted}',
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Scan with any UPI app, or use the ID below',
                  style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.textSecondaryLight),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                  ),
                  child: QrImageView(data: upiLink, size: 200, backgroundColor: Colors.white),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _copyUpiId,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(AppConstants.kUpiId, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(width: 6),
                        const Icon(Icons.copy_rounded, size: 16, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Payment Screenshot (optional)', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 8),
                ImagePickerField(
                  pickedPath: _pickedScreenshotPath,
                  existingUrl: null,
                  onPick: isSaving ? null : _pickScreenshot,
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  label: 'I Have Paid',
                  icon: Icons.check_circle_outline_rounded,
                  isLoading: isSaving,
                  onPressed: _confirmPayment,
                ),
                const SizedBox(height: 12),
                Text(
                  'The admin will confirm your payment shortly after.',
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
