import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/order_entity.dart';

class OrderStatusBadge extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      OrderStatus.pending => (AppColors.warning, 'Pending'),
      OrderStatus.confirmed => (AppColors.info, 'Confirmed'),
      OrderStatus.outForDelivery => (AppColors.primary, 'Out for Delivery'),
      OrderStatus.delivered => (AppColors.success, 'Delivered'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
