import '../../domain/entities/order_entity.dart';

/// Small, general-purpose extension methods used across the app.
extension StringCasingExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  bool get isBlank => trim().isEmpty;

  /// First 8 characters, upper-cased, for compact "Order #XXXXXXXX" labels.
  /// Falls back to the whole string if it's shorter than 8 — real order ids
  /// are always 36-char UUIDs, but nothing should crash on a shorter one.
  String get shortId => (length > 8 ? substring(0, 8) : this).toUpperCase();
}

extension DateTimeAgoExtension on DateTime {
  /// Short relative-time label, e.g. "2h ago", "3d ago", "just now".
  String get timeAgo {
    final difference = DateTime.now().difference(this);
    if (difference.inMinutes < 1) return 'just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${(difference.inDays / 7).floor()}w ago';
  }
}

/// Human-readable status labels, shared between `OrderStatusBadge` and the
/// admin status-update dropdown so both read the exact same wording.
extension OrderStatusLabelExtension on OrderStatus {
  String get label => switch (this) {
        OrderStatus.pending => 'Pending',
        OrderStatus.confirmed => 'Confirmed',
        OrderStatus.outForDelivery => 'Out for Delivery',
        OrderStatus.delivered => 'Delivered',
      };
}

extension ListChunkExtension<T> on List<T> {
  /// Splits a list into fixed-size chunks — useful for Firestore `whereIn`
  /// queries, which are capped at 10 values per query.
  List<List<T>> chunked(int size) {
    final chunks = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      chunks.add(sublist(i, i + size > length ? length : i + size));
    }
    return chunks;
  }
}
