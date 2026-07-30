import 'package:equatable/equatable.dart';
import 'money.dart';

/// Per-kg rate ladder for products sold by weight — the more you buy in one
/// line, the cheaper the kilo (client spec).
///
/// The three gram boundaries are fixed shop-wide; the four rates are set per
/// product by the admin on Add/Edit Product, because rice, sugar and dal
/// don't share a rate card.
///
/// The whole weight is billed at the single rate its band earns — this is
/// *not* tax-bracket style marginal pricing. Buying 3 kg costs 3 × ₹38, not
/// 240 g at ₹44 plus the rest cheaper.
class WeightRateSlabs extends Equatable {
  /// Anything under this is the most expensive band.
  static const int kSmallMaxGrams = 240;

  /// Upper bound (inclusive) of the second band.
  static const int kMediumMaxGrams = 999;

  /// Upper bound (inclusive) of the third band. Above it, bulk rate.
  static const int kLargeMaxGrams = 2400;

  /// ₹/kg for under 240 g.
  final double below240g;

  /// ₹/kg for 240 g – 999 g.
  final double upto999g;

  /// ₹/kg for 1 kg – 2.4 kg.
  final double upto2400g;

  /// ₹/kg above 2.4 kg.
  final double above2400g;

  const WeightRateSlabs({
    required this.below240g,
    required this.upto999g,
    required this.upto2400g,
    required this.above2400g,
  });

  /// Prefilled into the admin form for a new weighed product. Only a default
  /// — every product's rates are editable independently.
  static const defaults = WeightRateSlabs(
    below240g: 44,
    upto999g: 40,
    upto2400g: 39,
    above2400g: 38,
  );

  /// The ₹/kg that a purchase of [grams] earns.
  double ratePerKgFor(int grams) {
    if (grams < kSmallMaxGrams) return below240g;
    if (grams <= kMediumMaxGrams) return upto999g;
    if (grams <= kLargeMaxGrams) return upto2400g;
    return above2400g;
  }

  /// Line total for [grams], rounded to whole paise so a cart of many lines
  /// can't accumulate floating-point dust in its subtotal.
  Money priceFor(int grams) {
    final rupees = ratePerKgFor(grams) * grams / 1000;
    return Money((rupees * 100).round() / 100);
  }

  /// Human label for the band [grams] falls into, e.g. `240 g – 999 g`.
  String bandLabelFor(int grams) {
    if (grams < kSmallMaxGrams) return 'under 240 g';
    if (grams <= kMediumMaxGrams) return '240 g – 999 g';
    if (grams <= kLargeMaxGrams) return '1 kg – 2.4 kg';
    return 'above 2.4 kg';
  }

  /// Every band paired with its rate — what the product page renders as a
  /// rate table so the retailer can see the next discount before buying.
  List<({String label, double ratePerKg, int fromGrams})> get bands => [
        (label: 'under 240 g', ratePerKg: below240g, fromGrams: 0),
        (label: '240 g – 999 g', ratePerKg: upto999g, fromGrams: kSmallMaxGrams),
        (label: '1 kg – 2.4 kg', ratePerKg: upto2400g, fromGrams: kMediumMaxGrams + 1),
        (label: 'above 2.4 kg', ratePerKg: above2400g, fromGrams: kLargeMaxGrams + 1),
      ];

  /// The cheapest rate on the card — the "from ₹x/kg" teaser on a card.
  double get bestRatePerKg =>
      [below240g, upto999g, upto2400g, above2400g].reduce((a, b) => a < b ? a : b);

  static WeightRateSlabs? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    double? read(String key) => (json[key] as num?)?.toDouble();
    final b240 = read('below240g');
    final u999 = read('upto999g');
    final u2400 = read('upto2400g');
    final a2400 = read('above2400g');
    // A partially-written slab map is not usable for pricing — fall back to
    // the product's flat price rather than silently charging ₹0/kg.
    if (b240 == null || u999 == null || u2400 == null || a2400 == null) return null;
    return WeightRateSlabs(
      below240g: b240,
      upto999g: u999,
      upto2400g: u2400,
      above2400g: a2400,
    );
  }

  Map<String, dynamic> toJson() => {
        'below240g': below240g,
        'upto999g': upto999g,
        'upto2400g': upto2400g,
        'above2400g': above2400g,
      };

  @override
  List<Object?> get props => [below240g, upto999g, upto2400g, above2400g];
}
