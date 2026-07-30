import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// +/- quantity control used on Product Detail and Cart.
///
/// Counts whole units by default; pass [step]/[label] to drive it in grams
/// for a weight-priced line.
class QtyStepper extends StatelessWidget {
  final int qty;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

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
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            icon: Icons.remove_rounded,
            onTap: qty > min ? () => onChanged(qty - step) : null,
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 32),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              label ?? '$qty',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          _StepperButton(
            icon: Icons.add_rounded,
            onTap: qty < max ? () => onChanged((qty + step).clamp(min, max)) : null,
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 18,
          color: onTap == null ? AppColors.textSecondaryLight.withOpacity(0.4) : AppColors.primary,
        ),
      ),
    );
  }
}
