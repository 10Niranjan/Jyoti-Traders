import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/utils/app_logger.dart';
import '../../core/utils/extensions.dart';
import '../../core/utils/invoice_pdf.dart';
import '../../domain/entities/business_profile_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../l10n/app_localizations.dart';

/// App-bar action that builds the order's invoice as a PDF and opens the
/// share sheet (WhatsApp, email, print…). Shared by the retailer's and the
/// admin's order screens. Hidden for cancelled orders — nothing was sold.
class ShareInvoiceButton extends StatefulWidget {
  final OrderEntity order;

  /// The retailer's GST number, when they have one on file.
  final String? buyerGstin;

  /// The owner's legal name/address/GSTIN for the seller block; null falls
  /// back to the built-in defaults.
  final BusinessProfileEntity? seller;

  const ShareInvoiceButton({
    super.key,
    required this.order,
    this.buyerGstin,
    this.seller,
  });

  @override
  State<ShareInvoiceButton> createState() => _ShareInvoiceButtonState();
}

class _ShareInvoiceButtonState extends State<ShareInvoiceButton> {
  bool _busy = false;

  Future<void> _share() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final order = widget.order;
    setState(() => _busy = true);

    try {
      final bytes = await buildInvoicePdf(
        order,
        buyerGstin: widget.buyerGstin,
        seller: widget.seller,
      );
      // Wrapped like every other platform-plugin call in this codebase — the
      // share sheet isn't available on every platform or in a test run.
      try {
        await Share.shareXFiles([
          XFile.fromData(
            bytes,
            name: 'Invoice-${order.id.shortId}.pdf',
            mimeType: 'application/pdf',
          ),
        ], subject: 'Invoice #${order.id.shortId}');
      } catch (e) {
        logWarning('ShareInvoiceButton: share sheet unavailable', e);
      }
    } catch (e) {
      logWarning('ShareInvoiceButton: could not build the invoice PDF', e);
      messenger.showSnackBar(SnackBar(content: Text(l10n.orderInvoiceFailed)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.order.orderStatus == OrderStatus.cancelled) {
      return const SizedBox.shrink();
    }
    return IconButton(
      tooltip: AppLocalizations.of(context)!.orderInvoiceTooltip,
      onPressed: _busy ? null : _share,
      icon: _busy
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.picture_as_pdf_outlined),
    );
  }
}
