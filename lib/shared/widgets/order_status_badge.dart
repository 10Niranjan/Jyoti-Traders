import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/extensions.dart';
import '../../domain/entities/order_entity.dart';

class OrderStatusBadge extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      OrderStatus.pending => AppColors.warning,
      OrderStatus.confirmed => AppColors.info,
      OrderStatus.outForDelivery => AppColors.primary,
      OrderStatus.delivered => AppColors.success,
    };
    final label = status.label;

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
