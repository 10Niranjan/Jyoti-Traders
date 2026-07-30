import 'package:intl/intl.dart';

final NumberFormat _rupeeFormat = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 0,
);

final NumberFormat _rupeePaiseFormat = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 2,
);

/// Formats an amount as Indian Rupees, e.g. `formatRupees(2500)` → `₹2,500`.
///
/// Paise appear only when there are any — slab pricing bills part-kilos
/// (100 g at ₹44/kg is ₹4.40), and rounding that to `₹4` on screen would be
/// a visible money bug. Whole amounts stay clean.
String formatRupees(double amount) {
  final isWhole = amount == amount.roundToDouble();
  return (isWhole ? _rupeeFormat : _rupeePaiseFormat).format(amount);
}
