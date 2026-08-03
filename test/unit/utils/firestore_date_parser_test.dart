import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/core/utils/firestore_date_parser.dart';

void main() {
  group('Firestore Date Parser Utils', () {
    test('parseFirestoreDate with Timestamp should convert to DateTime', () {
      final dateTime = DateTime(2026, 7, 15, 12, 0);
      final timestamp = Timestamp.fromDate(dateTime);
      
      expect(parseFirestoreDate(timestamp), equals(dateTime));
    });

    test('parseFirestoreDate with DateTime should return the same DateTime', () {
      final dateTime = DateTime(2026, 7, 15, 12, 0);
      
      expect(parseFirestoreDate(dateTime), equals(dateTime));
    });

    test('parseFirestoreDate with null or invalid types should fallback to DateTime.now()', () {
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      final parsed = parseFirestoreDate('invalid_date_string');
      final after = DateTime.now().add(const Duration(seconds: 1));
      
      expect(parsed.isAfter(before), isTrue);
      expect(parsed.isBefore(after), isTrue);
    });
  });
}
