import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/core/utils/csv_encoder.dart';

void main() {
  group('encodeCsv', () {
    test('joins plain fields with commas and rows with CRLF', () {
      final csv = encodeCsv([
        ['Order ID', 'Total'],
        ['o1', 100],
      ]);

      expect(csv, 'Order ID,Total\r\no1,100');
    });

    test('quotes a field containing a comma', () {
      final csv = encodeCsv([
        ['Rice, Basmati'],
      ]);

      expect(csv, '"Rice, Basmati"');
    });

    test('quotes a field containing a newline', () {
      final csv = encodeCsv([
        ['Line1\nLine2'],
      ]);

      expect(csv, '"Line1\nLine2"');
    });

    test('doubles internal quotes and wraps the field in quotes', () {
      final csv = encodeCsv([
        ['5" pipe'],
      ]);

      expect(csv, '"5"" pipe"');
    });

    test('renders null as an empty field', () {
      final csv = encodeCsv([
        [null, 'x'],
      ]);

      expect(csv, ',x');
    });
  });
}
