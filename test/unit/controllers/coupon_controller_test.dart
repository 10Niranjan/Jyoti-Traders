import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/domain/value_objects/money.dart';
import 'package:traders_retailer/features/cart/controllers/coupon_controller.dart';

void main() {
  test('apply succeeds for a known code above its minimum order amount', () {
    final controller = CouponController();

    final result = controller.apply('welcome10', Money(3000));

    expect(result, isTrue);
    expect(controller.state.coupon?.code, 'WELCOME10');
    expect(controller.state.error, isNull);
  });

  test('apply fails for an unknown code and sets an error', () {
    final controller = CouponController();

    final result = controller.apply('NOPE', Money(3000));

    expect(result, isFalse);
    expect(controller.state.coupon, isNull);
    expect(controller.state.error, isNotNull);
  });

  test('apply fails below the coupon minimum and sets an error', () {
    final controller = CouponController();

    final result = controller.apply('WELCOME10', Money(1000));

    expect(result, isFalse);
    expect(controller.state.coupon, isNull);
    expect(controller.state.error, contains('more'));
  });

  test('remove clears both the applied coupon and any error', () {
    final controller = CouponController();
    controller.apply('NOPE', Money(3000));
    expect(controller.state.error, isNotNull);

    controller.remove();

    expect(controller.state.coupon, isNull);
    expect(controller.state.error, isNull);
  });
}
