import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tinted-background + colored-border + colored-text pill used for any
/// status/state label (order status, active/inactive, approved/pending).
/// One shared recipe so every status chip in the app reads as the same
/// visual system instead of each screen inventing its own badge styling.
class StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const StatusPill({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
