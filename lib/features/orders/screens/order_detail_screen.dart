import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/entities/order_entity.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../../shared/widgets/order_status_badge.dart';
import '../controllers/order_controller.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderByIdProvider(orderId));

    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => const ErrorStateWidget(),
        data: (order) {
          if (order == null) {
            return const ErrorStateWidget(message: 'This order could not be found.');
          }
          return _OrderDetailBody(order: order);
        },
      ),
    );
  }
}

class _OrderDetailBody extends StatelessWidget {
  final OrderEntity order;

  const _OrderDetailBody({required this.order});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Order #${order.id.substring(0, 8).toUpperCase()}',
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
