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
}
