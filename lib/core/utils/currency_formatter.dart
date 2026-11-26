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
  // Round to paise first: 210 × 1.10 is 231.00000000000003 in floating point
  // and must still read as a whole ₹231, not ₹231.00.
  final paise = (amount * 100).round() / 100;
  final isWhole = paise == paise.roundToDouble();
  return (isWhole ? _rupeeFormat : _rupeePaiseFormat).format(paise);
}

/// A ₹/kg rate for strings that already carry the ₹ (`"₹{rate}/kg"`):
/// `199.5` → `199.50`, `200` → `200`. Never rounded — the rate on screen must
/// be the rate charged, or "2.5 kg @ ₹200/kg = ₹498.75" stops adding up.
String formatRate(double rate) => formatRupees(rate).replaceFirst('₹', '');
