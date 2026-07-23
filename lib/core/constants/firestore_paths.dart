/// Firestore collection name constants — no magic strings in datasources.
class FirestorePaths {
  FirestorePaths._();

  static const String users = 'users';
  static const String categories = 'categories';
  static const String products = 'products';
  static const String orders = 'orders';

  /// Single-document config collection — not a list of many docs like the
  /// others above. `config/delivery` holds the warehouse coordinates and
  /// per-km delivery rate (Phase 5).
  static const String config = 'config';
  static const String deliveryConfigDoc = 'delivery';
}
