import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/core/utils/date_formatter.dart';

void main() {
  group('Date Formatter Utils', () {
    test('formatOrderDate formats correctly as d MMM yyyy', () {
      final date = DateTime(2026, 7, 15);
      expect(formatOrderDate(date), equals('15 Jul 2026'));
      
      final singleDigitDay = DateTime(2026, 7, 9);
      expect(formatOrderDate(singleDigitDay), equals('9 Jul 2026'));
    });

    test('formatOrderDateTime formats correctly with date and time', () {
      final date = DateTime(2026, 7, 15, 15, 45); // 3:45 PM
      expect(formatOrderDateTime(date), equals('15 Jul 2026, 3:45 PM'));

      final morningDate = DateTime(2026, 7, 9, 8, 5); // 8:05 AM
      expect(formatOrderDateTime(morningDate), equals('9 Jul 2026, 8:05 AM'));
    });
  });
}
