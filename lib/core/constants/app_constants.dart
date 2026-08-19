/// App-wide constants — business rules and static app metadata.
class AppConstants {
  AppConstants._();

  /// Minimum order amount enforced at checkout (PRD §3). Do not change
  /// without explicit client approval — see rules.md §11.
  static const double kMinOrderAmount = 2500.0;

  static const String kAppName = 'Jyoti Traders';
  static const String kSupportPhone = '9860460325';
  static const String kSupportEmail = 'vishvatejkatkar007@gmail.com';

  /// Stock at or below this level is flagged as "low" in the admin product
  /// list (phases.md §4.3).
  static const int kLowStockThreshold = 5;

  /// A retailer may self-cancel a still-`pending` order within this many
  /// minutes of placing it (phases.md §8).
  static const int kOrderCancellationWindowMinutes = 10;

  /// A product counts as "frequently bought" once it has appeared in at
  /// least this many of a retailer's own past orders (phases.md §8).
  static const int kFrequentOrderThreshold = 2;

  /// Flat placeholder delivery charge shown at checkout (Phase 3). Real
  /// per-km calculation via `geolocator` + warehouse coordinates + an
  /// admin-set per-km rate is Phase 5 scope — see phases.md §5.
  static const double kStubDeliveryCharge = 100.0;

  /// **Placeholder UPI details** — the client hasn't provided the owner's
  /// real UPI ID/QR yet. Replace before launch; nothing else in the UPI
  /// payment flow needs to change once real values are set here.
  static const String kUpiId = 'jyotitraders@upi';
  static const String kUpiPayeeName = 'Jyoti Traders Wholesale';
}
