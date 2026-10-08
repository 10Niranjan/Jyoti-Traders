import '../../domain/entities/order_entity.dart';
import 'date_formatter.dart';
import 'extensions.dart';
import 'weight_formatter.dart';

/// Plain-text order summary for the OS share sheet (WhatsApp, SMS, email) —
/// a receipt-style message, not a rendering of [OrderDetailBody].
String buildOrderShareText(OrderEntity order) {
  final buffer = StringBuffer()
    ..writeln('Jyoti Traders — Order #${order.id.shortId}')
    ..writeln(formatOrderDateTime(order.createdAt))
    ..writeln();

  for (final item in order.items) {
    final qty = item.isWeighed ? formatGrams(item.qty) : '× ${item.qty}';
    buffer.writeln('- ${item.name} $qty — ${item.totalPrice.formatted}');
  }

  buffer
    ..writeln()
    ..writeln('Subtotal: ${order.subtotal.formatted}')
    ..writeln('Delivery: ${order.deliveryCharge.formatted}')
    ..writeln('Total: ${order.grandTotal.formatted}')
    ..writeln()
    ..write('Status: ${order.orderStatus.label}');

  return buffer.toString();
}
