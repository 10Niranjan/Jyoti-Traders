import 'money.dart';

/// A percentage-off coupon, capped at [maxDiscount] and only valid once the
/// cart's subtotal reaches [minOrderAmount]. One shape covers every demo
/// coupon below — a flat-amount variant can be added if the client actually
/// asks for one, rather than building a polymorphic type nothing uses yet.
class Coupon {
  final String code;
  final double percentOff;
  final Money maxDiscount;
  final Money minOrderAmount;

  const Coupon({
    required this.code,
    required this.percentOff,
    required this.maxDiscount,
    required this.minOrderAmount,
  });

  /// Zero when [subtotal] hasn't reached [minOrderAmount] — callers show no
  /// discount line rather than an error in that case, since dropping an item
  /// after applying a coupon is a normal cart edit, not a mistake to flag.
  Money discountFor(Money subtotal) {
    if (subtotal < minOrderAmount) return Money.zero;
    final raw = Money(subtotal.amount * percentOff / 100);
    return raw < maxDiscount ? raw : maxDiscount;
  }
}

/// **Demo coupons** — no admin-facing coupon management exists yet (not
/// asked for); these are hardcoded placeholders the same way `AppConstants`
/// already placeholders the UPI ID, to swap for a real catalog once the
/// client defines actual promotions. `Money`'s validating constructor isn't
/// `const`, so this list is `final`, not `const` — same reasoning as
/// `DeliveryConfigModel.defaultConfig`.
final kDemoCoupons = <Coupon>[
  Coupon(
    code: 'WELCOME10',
    percentOff: 10,
    maxDiscount: Money(250),
    minOrderAmount: Money(2500),
  ),
  Coupon(
    code: 'FLAT5',
    percentOff: 5,
    maxDiscount: Money(500),
    minOrderAmount: Money(5000),
  ),
];

Coupon? findCoupon(String code) {
  final normalized = code.trim().toUpperCase();
  for (final c in kDemoCoupons) {
    if (c.code == normalized) return c;
  }
  return null;
}
