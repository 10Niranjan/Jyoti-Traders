import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// +/- quantity control used on Cart rows and Home's Buy Again/Today's Picks
/// rows.
///
/// Counts whole units by default; pass [step]/[label] to drive it in grams
/// for a weight-priced line. [filled] switches between Cart's neutral grey
/// fill (default) and Home's solid-violet fill, matching the Polished
/// reference's two different row-stepper looks.
class QtyStepper extends StatelessWidget {
  final int qty;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final bool filled;

  /// How much one tap moves [qty].
  final int step;

  /// Overrides the bare number, e.g. `2.5 kg`.
  final String? label;

  const QtyStepper({
    super.key,
    required this.qty,
    required this.onChanged,
    this.min = 0,
    this.max = 999,
    this.step = 1,
    this.label,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = filled
        ? Colors.white
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

    return Container(
      decoration: BoxDecoration(
        color: filled ? AppColors.primary : AppColors.cardBorder,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            icon: Icons.remove_rounded,
            color: textColor,
            onTap: qty > min ? () => onChanged(qty - step) : null,
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 32),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              label ?? '$qty',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: textColor,
              ),
            ),
          ),
          _StepperButton(
            icon: Icons.add_rounded,
            color: textColor,
            onTap: qty < max
                ? () => onChanged((qty + step).clamp(min, max))
                : null,
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StepperButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 18,
          color: onTap == null ? color.withOpacity(0.4) : color,
        ),
      ),
    );
  }
}
