import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/core/utils/currency_formatter.dart';

void main() {
  group('formatRupees', () {
    test('zero', () {
      expect(formatRupees(0), '₹0');
    });

    test('whole amount has no decimals', () {
      expect(formatRupees(2500), '₹2,500');
    });

    test('large number gets Indian digit grouping', () {
      expect(formatRupees(1234567), '₹12,34,567');
    });

    test('fractional amount keeps paise', () {
      expect(formatRupees(4.4), '₹4.40');
    });

    test('fractional large amount groups and keeps paise', () {
      expect(formatRupees(123456.5), '₹1,23,456.50');
    });
  });

  group('formatRate', () {
    test('keeps paise instead of rounding the rate that is charged', () {
      // 2.5 kg billed at ₹199.50/kg = ₹498.75 — showing "₹200/kg" lied.
      expect(formatRate(199.5), '199.50');
      expect(formatRate(204.75), '204.75');
    });

    test('whole rates stay clean, with no ₹ (the string adds it)', () {
      expect(formatRate(200), '200');
      expect(formatRate(1320), '1,320');
    });

    test('floating-point dust does not add a fake .00', () {
      expect(formatRate(210 * 1.10), '231'); // 231.00000000000003
    });
  });
}
