import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/product_entity.dart';
import '../../l10n/app_localizations.dart';

/// Inline "how much?" picker embedded directly on Product Detail — quick-pick
/// chips, a typed custom amount, and a doubling +/- stepper, all driving the
/// same [qty] (grams for a weighed product, whole units otherwise) so the
/// page's price — and, for a weighed product, the rate table's highlighted
/// band — update live as the retailer picks.
class QuantityPicker extends StatefulWidget {
  final ProductEntity product;
  final int qty;
  final ValueChanged<int> onChanged;

  const QuantityPicker({
    super.key,
    required this.product,
    required this.qty,
    required this.onChanged,
  });

  @override
  State<QuantityPicker> createState() => _QuantityPickerState();
}

class _QuantityPickerState extends State<QuantityPicker> {
  late final TextEditingController _field;

  ProductEntity get _p => widget.product;
  bool get _weighed => _p.isWeighed;

  @override
  void initState() {
    super.initState();
    _field = TextEditingController(text: _fieldText(widget.qty));
  }

  @override
  void didUpdateWidget(covariant QuantityPicker old) {
    super.didUpdateWidget(old);
    // A preset tap or the +/- stepper both change `qty` via `onChanged` ->
    // the parent's `setState` -> a new `widget.qty` here. Keep the typed
    // field in sync with that round-trip, but only rewrite it when it
    // doesn't already show the current value, so a mid-keystroke rebuild
    // (the parent also rebuilds the rate table on every change) never
    // fights the user's cursor.
    if (_parse(_field.text) != widget.qty) {
      _field.text = _fieldText(widget.qty);
    }
  }

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  /// Weight is typed in kilos — `2.5`, not `2500` — so the number matches
  /// the unit printed beside it. Trailing zeros trimmed so `1.000` reads
  /// back as `1`.
  String _fieldText(int qty) => _weighed
      ? (qty / 1000).toStringAsFixed(3).replaceAll(RegExp(r'\.?0+$'), '')
      : '$qty';

  int? _parse(String raw) {
    final value = double.tryParse(raw.trim());
    if (value == null) return null;
    return _weighed ? (value * 1000).round() : value.round();
  }

  /// Weight presets straddle every rate band so each rate on the card is one
  /// tap away; unit presets are just common counts. Capped at what's in stock.
  List<int> get _presets =>
      (_weighed ? const [250, 500, 1000, 2500, 5000, 10000] : const [1, 2, 5, 10, 25])
          .where((q) => q <= _p.maxQty)
          .toList();

  void _set(int qty) {
    final clamped = qty.clamp(0, _p.maxQty);
    widget.onChanged(clamped);
    setState(() => _field.text = _fieldText(clamped));
  }

  /// Parses as the user types. Deliberately does *not* rewrite the field —
  /// clamping mid-keystroke would fight the cursor.
  void _onTyped(String raw) {
    final parsed = _parse(raw);
    widget.onChanged(parsed == null ? 0 : parsed.clamp(0, _p.maxQty));
  }

  /// +/- doubles or halves the quantity instead of nudging by a fixed step —
  /// gets from a small starting amount (100 g) to a bulk one (1.6 kg) in a
  /// handful of taps instead of dozens.
  void _double() => _set(widget.qty <= 0 ? _p.minQty : widget.qty * 2);
  void _halve() => _set((widget.qty / 2).floor());

  @override
  Widget build(BuildContext context) {
    final qty = widget.qty;
    final valid = qty >= _p.minQty && qty <= _p.maxQty;
    final total = valid ? _p.priceForQty(qty) : null;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quantityPickerSelectQuantity,
          style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final preset in _presets)
              ChoiceChip(
                label: Text(_p.labelForQty(preset)),
                labelStyle: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: preset == qty ? Colors.white : AppColors.primary,
                ),
                selected: preset == qty,
                selectedColor: AppColors.primary,
                backgroundColor: Colors.transparent,
                showCheckmark: false,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: preset == qty ? AppColors.primary : AppColors.primary.withOpacity(0.35),
                  ),
                ),
                onSelected: (_) => _set(preset),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _field,
                keyboardType: TextInputType.numberWithOptions(decimal: _weighed),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(_weighed ? RegExp(r'[0-9.]') : RegExp(r'[0-9]')),
                ],
                onChanged: _onTyped,
                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: l10n.quantityPickerCustomQuantity,
                  suffixText: _weighed ? 'kg' : _p.unit.value,
                  helperText: l10n.quantitySheetInStock(_p.labelForQty(_p.maxQty)),
                  errorText: qty > 0 && qty < _p.minQty ? l10n.quantitySheetMinimum(_p.labelForQty(_p.minQty)) : null,
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _StepButton(icon: Icons.remove_rounded, onTap: qty > _p.minQty ? _halve : null),
                  SizedBox(
                    width: 60,
                    child: Text(
                      _p.labelForQty(qty),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  _StepButton(icon: Icons.add_rounded, onTap: qty < _p.maxQty ? _double : null),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
                total?.formatted ?? '—',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
              )
              // A quantity change re-prices the line — a quick pop is the
              // same "it moved" feedback the chips' own selected-color
              // transition already gives, so the total doesn't just
              // silently jump to a new number.
              .animate(key: ValueKey(qty))
              .scale(begin: const Offset(1.1, 1.1), end: const Offset(1, 1), duration: 150.ms, curve: Curves.easeOut),
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepButton({required this.icon, required this.onTap});

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
