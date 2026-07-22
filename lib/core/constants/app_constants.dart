/// App-wide constants — business rules and static app metadata.
class AppConstants {
  AppConstants._();

  /// Minimum order amount enforced at checkout (PRD §3). Do not change
  /// without explicit client approval — see rules.md §11.
  static const double kMinOrderAmount = 2500.0;

  static const String kAppName = 'Jyoti Kirana';
  static const String kSupportPhone = '9860460325';
  static const String kSupportEmail = 'vishvatejkatkar007@gmail.com';

  /// Stock at or below this level is flagged as "low" in the admin product
  /// list (phases.md §4.3).
  static const int kLowStockThreshold = 5;

  /// Flat placeholder delivery charge shown at checkout (Phase 3). Real
  /// per-km calculation via `geolocator` + warehouse coordinates + an
  /// admin-set per-km rate is Phase 5 scope — see phases.md §5.
  static const double kStubDeliveryCharge = 100.0;
}
