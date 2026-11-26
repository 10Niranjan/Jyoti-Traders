import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/domain/value_objects/coupon.dart';
import 'package:traders_retailer/domain/value_objects/money.dart';

void main() {
  final coupon = Coupon(
    code: 'WELCOME10',
    percentOff: 10,
    maxDiscount: Money(250),
    minOrderAmount: Money(2500),
  );

  test('discountFor is zero below the minimum order amount', () {
    expect(coupon.discountFor(Money(2000)).amount, 0);
  });

  test('discountFor computes the percentage when under the cap', () {
    expect(
      coupon.discountFor(Money(2500)).amount,
      250,
    ); // 10% of 2500 == 250, exactly the cap
    expect(coupon.discountFor(Money(2000 + 500)).amount, 250);
  });

  test('discountFor is capped at maxDiscount for a large subtotal', () {
    expect(
      coupon.discountFor(Money(10000)).amount,
      250,
    ); // 10% would be 1000, capped to 250
  });

  test('findCoupon matches case-insensitively and trims whitespace', () {
    expect(findCoupon('welcome10')?.code, 'WELCOME10');
    expect(findCoupon('  WELCOME10  ')?.code, 'WELCOME10');
  });

  test('findCoupon returns null for an unknown code', () {
    expect(findCoupon('NOPE'), isNull);
  });
}
