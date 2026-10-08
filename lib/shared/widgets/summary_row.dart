import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_colors.dart';

/// A label/value line in an order-total breakdown — shared by Cart and
/// Checkout so both price summaries render identically.
class SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  const SummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.inter(
      fontSize: bold ? 15 : 13,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    );
    // The amount is what the retailer reads, so it is always full-strength;
    // the label of a plain line steps back, the Total label doesn't.
    final labelColor = bold ? context.textPrimary : context.textSecondary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style.copyWith(color: labelColor)),
          Text(
            value,
            style: style.copyWith(color: valueColor ?? context.textPrimary),
          ),
        ],
      ),
    );
  }
}
