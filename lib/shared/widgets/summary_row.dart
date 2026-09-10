import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(
            value,
            style: valueColor == null
                ? style
                : style.copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }
}
