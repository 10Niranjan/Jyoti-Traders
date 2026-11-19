import 'package:firebase_analytics/firebase_analytics.dart';
import '../utils/app_logger.dart';

/// Thin wrapper around `firebase_analytics`, same defensive shape as
/// [FcmService]/[FirebaseCrashlytics] elsewhere in this app: every call is
/// wrapped in its own try/catch and degrades to a no-op rather than
/// throwing, since analytics is never allowed to break the feature it's
/// observing.
class AnalyticsService {
  FirebaseAnalytics get _instance => FirebaseAnalytics.instance;

  Future<void> logLogin(String role) async {
    try {
      await _instance.logLogin(loginMethod: role);
    } catch (e) {
      logWarning('AnalyticsService: logLogin failed, skipping', e);
    }
  }

  Future<void> logSignUp(String role) async {
    try {
      await _instance.logSignUp(signUpMethod: role);
    } catch (e) {
      logWarning('AnalyticsService: logSignUp failed, skipping', e);
    }
  }

  Future<void> logOrderPlaced({
    required String orderId,
    required double value,
    required String paymentMethod,
  }) async {
    try {
      await _instance.logPurchase(
        transactionId: orderId,
        value: value,
        currency: 'INR',
        parameters: {'payment_method': paymentMethod},
      );
    } catch (e) {
      logWarning('AnalyticsService: logOrderPlaced failed, skipping', e);
    }
  }
}
