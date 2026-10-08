import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/value_objects/coupon.dart';
import '../../../domain/value_objects/money.dart';

/// Which coupon (if any) is applied this session, plus the last validation
/// error to show under the input field. Session-only — not persisted to
/// Hive alongside the cart, so it resets on app restart; `discountFor()` is
/// recomputed live off the current subtotal wherever it's read, so a cart
/// edit that drops below the coupon's minimum silently zeroes the discount
/// rather than needing its own invalidation path.
class CouponState {
  final Coupon? coupon;
  final String? error;

  const CouponState({this.coupon, this.error});
}

class CouponController extends StateNotifier<CouponState> {
  CouponController() : super(const CouponState());

  /// Returns true on success so the input field can be cleared by the caller.
  bool apply(String code, Money subtotal) {
    final match = findCoupon(code);
    if (match == null) {
      state = const CouponState(error: 'Invalid coupon code');
      return false;
    }
    if (subtotal < match.minOrderAmount) {
      state = CouponState(
        error:
            'Add ${(match.minOrderAmount - subtotal).formatted} more to use this coupon',
      );
      return false;
    }
    state = CouponState(coupon: match);
    return true;
  }

  void remove() => state = const CouponState();
}

final couponControllerProvider =
    StateNotifierProvider<CouponController, CouponState>((ref) {
      return CouponController();
    });
