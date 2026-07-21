import 'package:intl/intl.dart';

final NumberFormat _rupeeFormat = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 0,
);

/// Formats an amount as Indian Rupees, e.g. `formatRupees(2500)` → `₹2,500`.
String formatRupees(double amount) => _rupeeFormat.format(amount);
