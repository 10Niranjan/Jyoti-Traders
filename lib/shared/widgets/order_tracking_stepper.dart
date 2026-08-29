import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/order_entity.dart';

/// Vertical progress timeline for an order's lifecycle — Placed → Confirmed
/// → Out for Delivery → Delivered. A cancelled order is a branch, not a
/// stalled point on that line, so it renders as its own single row instead.
///
/// Keyed on [status] so completed steps pop in and their connector lines
/// fill in sequence — replaying live if the status advances while this
/// screen is open, not just on first load.
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
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    if (status == OrderStatus.cancelled) {
      final row = Row(
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
      return reduceMotion
          ? row
          : row.animate().fadeIn(duration: 250.ms).scaleXY(begin: 0.92);
    }

    final currentIndex = _steps.indexWhere((s) => s.$1 == status);

    return Column(
      key: ValueKey(status),
      children: [
        for (var i = 0; i < _steps.length; i++)
          _StepRow(
            icon: _steps[i].$3,
            label: _steps[i].$2,
            isDone: i <= currentIndex,
            isLast: i == _steps.length - 1,
            index: i,
            reduceMotion: reduceMotion,
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
  final int index;
  final bool reduceMotion;

  const _StepRow({
    required this.icon,
    required this.label,
    required this.isDone,
    required this.isLast,
    required this.index,
    required this.reduceMotion,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDone
        ? AppColors.primary
        : AppColors.textSecondaryLight.withOpacity(0.4);
    final delay = Duration(milliseconds: index * 180);

    final dot = Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: isDone ? AppColors.primary : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.5),
      ),
      child: Icon(icon, size: 14, color: isDone ? Colors.white : color),
    );

    final line = Container(
      width: 2,
      margin: const EdgeInsets.symmetric(vertical: 2),
      color: isDone ? AppColors.primary.withOpacity(0.4) : color,
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              isDone && !reduceMotion
                  ? dot
                        .animate(delay: delay)
                        .scale(
                          begin: const Offset(0.4, 0.4),
                          curve: Curves.elasticOut,
                          duration: 420.ms,
                        )
                        .fadeIn(duration: 200.ms)
                  : dot,
              if (!isLast)
                Expanded(
                  child: isDone && !reduceMotion
                      ? _AnimatedLine(baseColor: color, delay: delay + 250.ms)
                      : line,
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

/// The connector line for a completed step — fades from the muted resting
/// color to a filled brand color instead of just popping in, echoing the
/// progress-line fill from the web design reference.
class _AnimatedLine extends StatelessWidget {
  final Color baseColor;
  final Duration delay;

  const _AnimatedLine({required this.baseColor, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Container(
          width: 2,
          margin: const EdgeInsets.symmetric(vertical: 2),
          color: baseColor,
        )
        .animate(delay: delay)
        .custom(
          duration: 350.ms,
          curve: Curves.easeOut,
          builder: (context, t, _) => Container(
            width: 2,
            margin: const EdgeInsets.symmetric(vertical: 2),
            color: Color.lerp(baseColor, AppColors.primary.withOpacity(0.4), t),
          ),
        );
  }
}
