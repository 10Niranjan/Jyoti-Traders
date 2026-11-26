import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/domain/value_objects/coupon.dart';

/// firestore.rules re-states every coupon so the server can reject a forged
/// discount. This fails the moment a coupon in the app and its rule clause
/// drift apart (changed code, percent, cap or minimum).
void main() {
  test('every app coupon has a matching clause in firestore.rules', () {
    final rules = File('firestore.rules').readAsStringSync();
    for (final c in kDemoCoupons) {
      final clause =
          "code == '${c.code}' && sub >= ${c.minOrderAmount.amount.toInt()}"
          ' && disc <= sub * ${(c.percentOff / 100).toStringAsFixed(2)} + 0.01'
          ' && disc <= ${c.maxDiscount.amount.toInt()}';
      expect(rules, contains(clause), reason: 'rules out of step for ${c.code}');
    }
  });
}
