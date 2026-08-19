import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/order_entity.dart';

/// Vertical progress timeline for an order's lifecycle — Placed → Confirmed
/// → Out for Delivery → Delivered. A cancelled order is a branch, not a
/// stalled point on that line, so it renders as its own single row instead.
class OrderTrackingStepper extends StatelessWidget {
  final OrderStatus status;

  const OrderTrackingStepper({super.key, required this.status});

  static const _steps = [
    (OrderStatus.pending, 'Order Placed', Icons.receipt_long_outlined),
    (OrderStatus.confirmed, 'Confirmed', Icons.task_alt_rounded),
    (
      OrderStatus.outForDelivery,
      'Out for Delivery',
      Icons.local_shipping_outlined,
    ),
    (OrderStatus.delivered, 'Delivered', Icons.home_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    if (status == OrderStatus.cancelled) {
      return Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.close_rounded,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Order Cancelled',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
              color: AppColors.error,
            ),
          ),
        ],
      );
    }

    final currentIndex = _steps.indexWhere((s) => s.$1 == status);

    return Column(
      children: [
        for (var i = 0; i < _steps.length; i++)
          _StepRow(
            icon: _steps[i].$3,
            label: _steps[i].$2,
            isDone: i <= currentIndex,
            isLast: i == _steps.length - 1,
          ),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDone;
  final bool isLast;

  const _StepRow({
    required this.icon,
    required this.label,
    required this.isDone,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDone
        ? AppColors.primary
        : AppColors.textSecondaryLight.withOpacity(0.4);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: isDone ? AppColors.primary : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 1.5),
                ),
                child: Icon(
                  icon,
                  size: 14,
                  color: isDone ? Colors.white : color,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    color: isDone ? AppColors.primary.withOpacity(0.4) : color,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 16),
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: isDone ? FontWeight.w600 : FontWeight.w400,
                color: isDone ? null : AppColors.textSecondaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
