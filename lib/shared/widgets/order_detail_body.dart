import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/extensions.dart';
import '../../core/utils/weight_formatter.dart';
import '../../domain/entities/order_entity.dart';
import '../../l10n/app_localizations.dart';
import 'order_status_badge.dart';
import 'order_tracking_stepper.dart';
import 'status_pill.dart';

/// Full order breakdown — id/status, items, totals, delivery address and
/// payment method. Shared by the retailer's read-only `OrderDetailScreen`
/// and the admin's `OrderManagementScreen`, which additionally shows the
/// shop name, injects a status-update control via [header], and injects
/// payment-confirmation controls (a "Mark as Paid" button) via [paymentExtra].
class OrderDetailBody extends StatelessWidget {
  final OrderEntity order;
  final bool showShopName;
  final Widget? header;
  final Widget? paymentExtra;

  const OrderDetailBody({
    super.key,
    required this.order,
    this.showShopName = false,
    this.header,
    this.paymentExtra,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.orderNumber(order.id.shortId),
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            OrderStatusBadge(status: order.orderStatus),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          formatOrderDateTime(order.createdAt),
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.textSecondaryLight,
          ),
        ),
        if (showShopName) ...[
          const SizedBox(height: 4),
          Text(
            order.shopName,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
        if (header != null) ...[const SizedBox(height: 16), header!],
        const SizedBox(height: 20),
        Text(
          l10n.orderStatusHeading,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        OrderTrackingStepper(status: order.orderStatus),
        Text(l10n.orderItemsHeading, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ...order.items.map(
          (item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.isWeighed
                        ? l10n.orderWeighedLine(
                            item.name, formatGrams(item.qty), item.unitPrice.amount.toStringAsFixed(0))
                        : l10n.orderUnitLine(item.name, item.qty),
                    style: GoogleFonts.inter(fontSize: 13),
                  ),
                ),
                Text(
                  item.totalPrice.formatted,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 28),
        _TotalRow(label: l10n.cartSubtotal, value: order.subtotal.formatted),
        _TotalRow(
          label: l10n.checkoutDeliveryCharge,
          value: order.deliveryCharge.formatted,
        ),
        _TotalRow(
          label: l10n.checkoutGrandTotal,
          value: order.grandTotal.formatted,
          bold: true,
        ),
        const SizedBox(height: 24),
        Text(
          l10n.orderDeliveryAddressHeading,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
            color: AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.orderAddressLine(order.deliveryAddress.street, order.deliveryAddress.city, order.deliveryAddress.pincode),
          style: GoogleFonts.inter(fontSize: 13),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.orderPaymentHeading,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
            color: AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          order.paymentMethod == PaymentMethod.cod ? l10n.orderPaymentCod : l10n.checkoutUpi,
          style: GoogleFonts.inter(fontSize: 13),
        ),
        const SizedBox(height: 6),
        StatusPill(
          label: order.paymentStatus.label,
          color: order.paymentStatus == PaymentStatus.paid
              ? AppColors.success
              : AppColors.warning,
        ),
        if (order.paymentScreenshotUrl != null) ...[
          const SizedBox(height: 10),
          Text(
            l10n.orderPaymentScreenshotLabel,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 140,
              height: 140,
              child: order.paymentScreenshotUrl!.startsWith('http')
                  ? CachedNetworkImage(
                      imageUrl: order.paymentScreenshotUrl!,
                      fit: BoxFit.cover,
                    )
                  : Image.file(
                      File(order.paymentScreenshotUrl!),
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        ],
        if (paymentExtra != null) ...[
          const SizedBox(height: 12),
          paymentExtra!,
        ],
      ],
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _TotalRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.inter(
      fontSize: bold ? 15 : 13,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}
