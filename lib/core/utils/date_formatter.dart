import 'package:intl/intl.dart';

final DateFormat _orderDateFormat = DateFormat('d MMM yyyy');
final DateFormat _orderDateTimeFormat = DateFormat('d MMM yyyy, h:mm a');

/// Formats a date for order lists/receipts, e.g. `15 Jul 2026`.
String formatOrderDate(DateTime date) => _orderDateFormat.format(date);

/// Formats a date with time, e.g. `15 Jul 2026, 3:45 PM`.
String formatOrderDateTime(DateTime date) => _orderDateTimeFormat.format(date);
