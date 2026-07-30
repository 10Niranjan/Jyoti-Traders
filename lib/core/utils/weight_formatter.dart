/// How much a ± tap moves a weight, in grams. Coarser as the weight grows —
/// nobody nudges a 10 kg order by 100 g.
int weightStepFor(int grams) => grams < 1000 ? 100 : (grams < 5000 ? 500 : 1000);

/// Default weight a one-tap "add" puts in the cart: a round kilo, or all the
/// stock left if there's less than that.
int defaultAddGrams(int maxGrams) => maxGrams < 1000 ? maxGrams : 1000;

/// Formats a gram quantity the way a shopkeeper says it: `250 g`, `1 kg`,
/// `2.5 kg`, `12.75 kg`.
String formatGrams(int grams) {
  if (grams < 1000) return '$grams g';
  final kg = grams / 1000;
  // Trim trailing zeros: 2.500 -> 2.5, 3.000 -> 3.
  final text = kg.toStringAsFixed(3).replaceAll(RegExp(r'\.?0+$'), '');
  return '$text kg';
}
