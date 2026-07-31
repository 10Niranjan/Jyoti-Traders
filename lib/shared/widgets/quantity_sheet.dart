import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/weight_formatter.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../features/cart/controllers/cart_controller.dart';
import 'primary_button.dart';

/// The "how much?" step a `+` tap now leads to, instead of silently dropping
/// a default 1 kg / 1 unit in the cart: quick-pick chips *plus* a typed
/// quantity, so an odd order (7 kg of dal, 13 boxes) doesn't mean thirteen
/// taps on a stepper.
///
/// Sets the line to exactly what's picked — it seeds from whatever is already
/// in the cart, so re-opening it reads as editing that line, not stacking a
/// second one on top.
Future<void> showQuantitySheet(BuildContext context, ProductEntity product) {
  return showModalBottomSheet<void>(
    context: context,
    // Without this the sheet is capped at half the screen and the keyboard
    // covers the very field this sheet exists for.
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _QuantitySheet(product: product),
  );
}

class _QuantitySheet extends ConsumerStatefulWidget {
  final ProductEntity product;

  const _QuantitySheet({required this.product});

  @override
  ConsumerState<_QuantitySheet> createState() => _QuantitySheetState();
}

class _QuantitySheetState extends ConsumerState<_QuantitySheet> {
  late final TextEditingController _field;

  /// Grams for a weighed product, whole units otherwise. Sits at 0 while the
  /// field holds nothing parseable, which is what disables the confirm button.
  late int _qty;

  ProductEntity get _p => widget.product;

  @override
  void initState() {
    super.initState();
    final inCart = ref.read(cartControllerProvider).qtyFor(_p.id);
    _qty = inCart > 0 ? inCart : (_p.isWeighed ? defaultAddGrams(_p.maxQty) : 1);
    _field = TextEditingController(text: _fieldText(_qty));
  }

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  /// Weight is typed in kilos — `2.5`, not `2500` — so the number matches the
  /// unit printed beside it. Trailing zeros trimmed the same way
  /// [formatGrams] does, so `1.000` reads back as `1`.
  String _fieldText(int qty) => _p.isWeighed
      ? (qty / 1000).toStringAsFixed(3).replaceAll(RegExp(r'\.?0+$'), '')
      : '$qty';

  /// How a quantity reads in prose: `2.5 kg`, or `3 box`.
  String _label(int qty) =>
      _p.isWeighed ? formatGrams(qty) : '$qty ${_p.unit.value}';

  /// Weight presets straddle every rate band (as `WeightSelector`'s do) so
  /// each rate on the card is one tap away; unit presets are just common
  /// counts. Capped at what's actually in stock.
  List<int> get _presets =>
      (_p.isWeighed ? const [250, 500, 1000, 2500, 5000, 10000] : const [1, 2, 5, 10, 25])
          .where((q) => q <= _p.maxQty)
          .toList();

  void _pick(int qty) {
    setState(() => _qty = qty);
    _field.text = _fieldText(qty);
  }

  /// Parses as the user types. Deliberately does *not* rewrite the field —
  /// clamping mid-keystroke would fight the cursor. The confirm button's
  /// label always shows the quantity that will actually be ordered.
  void _onTyped(String raw) {
    final value = double.tryParse(raw.trim());
    setState(() {
      _qty = value == null
          ? 0
          : (_p.isWeighed ? (value * 1000).round() : value.round()).clamp(0, _p.maxQty);
    });
  }

  void _confirm() {
    final notifier = ref.read(cartControllerProvider.notifier);
    // `addItem` *sums* into an existing line; this sheet sets an exact amount,
    // so anything already in the cart has to go through updateQty instead or
    // picking "2 kg" on a line that already holds 2 kg would silently make 4.
    if (ref.read(cartControllerProvider).qtyFor(_p.id) > 0) {
      notifier.updateQty(_p.id, _qty);
    } else {
      notifier.addItem(
        CartItemEntity(
          productId: _p.id,
          name: _p.name,
          imageUrl: _p.imageUrl,
          unitPrice: _p.price,
          unit: _p.unit,
          qty: _qty,
          rateSlabs: _p.rateSlabs,
        ),
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inCart = ref.watch(
      cartControllerProvider.select((cart) => cart.qtyFor(_p.id)),
    );
    final valid = _qty >= _p.minQty && _qty <= _p.maxQty;
    final total = valid ? _p.priceForQty(_qty) : null;
    final secondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: secondary.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _Header(product: _p, isDark: isDark, secondary: secondary),
                const SizedBox(height: 18),
                TextField(
                  controller: _field,
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: _p.isWeighed,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      _p.isWeighed ? RegExp(r'[0-9.]') : RegExp(r'[0-9]'),
                    ),
                  ],
                  onChanged: _onTyped,
                  onSubmitted: (_) {
                    if (valid) _confirm();
                  },
                  style: GoogleFonts.poppins(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    suffixText: _p.isWeighed ? 'kg' : _p.unit.value,
                    helperText: 'In stock: ${_label(_p.maxQty)}',
                    errorText: _qty > 0 && _qty < _p.minQty
                        ? 'Minimum ${_label(_p.minQty)}'
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final preset in _presets)
                      ChoiceChip(
                        label: Text(_label(preset)),
                        labelStyle: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: preset == _qty ? Colors.white : AppColors.primary,
                        ),
                        selected: preset == _qty,
                        selectedColor: AppColors.primary,
                        backgroundColor: Colors.transparent,
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: preset == _qty ? AppColors.primary : AppColors.primary.withOpacity(0.4),
                          ),
                        ),
                        onSelected: (_) => _pick(preset),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        _p.isWeighed
                            ? (valid
                                  ? '₹${_p.rateSlabs!.ratePerKgFor(_qty).toStringAsFixed(0)}/kg · ${_p.rateSlabs!.bandLabelFor(_qty)}'
                                  : 'from ₹${_p.rateSlabs!.bestRatePerKg.toStringAsFixed(0)}/kg')
                            : '${_p.price.formatted} per ${_p.unit.value}',
                        style: GoogleFonts.inter(fontSize: 11.5, color: secondary),
                      ),
                    ),
                    Text(
                      total?.formatted ?? '—',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    )
                        // A quantity change re-prices the line — a quick pop
                        // is the same "it moved" feedback the preset chips'
                        // own selected-color transition already gives, so the
                        // total doesn't just silently jump to a new number.
                        .animate(key: ValueKey(_qty))
                        .scale(
                          begin: const Offset(1.15, 1.15),
                          end: const Offset(1, 1),
                          duration: 150.ms,
                          curve: Curves.easeOut,
                        ),
                  ],
                ),
                const SizedBox(height: 14),
                PrimaryButton(
                  label: !valid
                      ? 'Enter a quantity'
                      : inCart > 0
                      ? 'Update to ${_label(_qty)}'
                      : 'Add ${_label(_qty)} to Cart',
                  icon: Icons.shopping_cart_outlined,
                  onPressed: valid ? _confirm : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final ProductEntity product;
  final bool isDark;
  final Color secondary;

  const _Header({
    required this.product,
    required this.isDark,
    required this.secondary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: isDark ? Colors.white12 : Colors.black12,
            borderRadius: BorderRadius.circular(10),
          ),
          clipBehavior: Clip.antiAlias,
          child: product.imageUrl.isEmpty
              ? const Icon(Icons.image_outlined, size: 22)
              : CachedNetworkImage(
                  imageUrl: product.imageUrl,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.image_outlined, size: 22),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                product.isWeighed
                    ? 'from ₹${product.rateSlabs!.bestRatePerKg.toStringAsFixed(0)}/kg'
                    : 'Sold per ${product.unit.value}',
                style: GoogleFonts.inter(fontSize: 11.5, color: secondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
