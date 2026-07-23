import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/extensions.dart';
import '../../domain/entities/order_entity.dart';
import 'order_status_badge.dart';

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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Order #${order.id.shortId}',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            OrderStatusBadge(status: order.orderStatus),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          formatOrderDateTime(order.createdAt),
          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondaryLight),
        ),
        if (showShopName) ...[
          const SizedBox(height: 4),
          Text(
            order.shopName,
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
          ),
        ],
        if (header != null) ...[
          const SizedBox(height: 16),
          header!,
        ],
        const SizedBox(height: 20),
        Text('Items', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ...order.items.map(
          (item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text('${item.name} × ${item.qty}', style: GoogleFonts.inter(fontSize: 13))),
                Text(item.totalPrice.formatted, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
        const Divider(height: 28),
        _TotalRow(label: 'Subtotal', value: order.subtotal.formatted),
        _TotalRow(label: 'Delivery Charge', value: order.deliveryCharge.formatted),
        _TotalRow(label: 'Grand Total', value: order.grandTotal.formatted, bold: true),
        const SizedBox(height: 24),
        Text('Delivery Address', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(
          '${order.deliveryAddress.street}, ${order.deliveryAddress.city} - ${order.deliveryAddress.pincode}',
          style: GoogleFonts.inter(fontSize: 13),
        ),
        const SizedBox(height: 24),
        Text('Payment', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(
          order.paymentMethod == PaymentMethod.cod ? 'Cash on Delivery' : 'UPI',
          style: GoogleFonts.inter(fontSize: 13),
        ),
        if (order.paymentMethod == PaymentMethod.upi) ...[
          const SizedBox(height: 4),
          Text(
            order.paymentStatus.label,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: order.paymentStatus == PaymentStatus.paid ? AppColors.success : AppColors.warning,
            ),
          ),
          if (order.paymentScreenshotUrl != null) ...[
            const SizedBox(height: 10),
            Text('Payment Screenshot', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 140,
                height: 140,
                child: order.paymentScreenshotUrl!.startsWith('http')
                    ? CachedNetworkImage(imageUrl: order.paymentScreenshotUrl!, fit: BoxFit.cover)
                    : Image.file(File(order.paymentScreenshotUrl!), fit: BoxFit.cover),
              ),
            ),
          ],
          if (paymentExtra != null) ...[
            const SizedBox(height: 12),
            paymentExtra!,
          ],
        ],
      ],
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _TotalRow({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.inter(fontSize: bold ? 15 : 13, fontWeight: bold ? FontWeight.bold : FontWeight.normal);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: style), Text(value, style: style)],
      ),
    );
  }
}
