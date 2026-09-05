import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/extensions.dart';
import '../../domain/entities/order_entity.dart';
import 'status_pill.dart';

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
      OrderStatus.cancelled => AppColors.error,
    };

    return StatusPill(label: status.label, color: color);
  }
}
