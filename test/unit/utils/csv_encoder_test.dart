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

  group('decodeCsv', () {
    test('splits plain rows on commas and newlines', () {
      final rows = decodeCsv('a,b,c\nd,e,f');
      expect(rows, [
        ['a', 'b', 'c'],
        ['d', 'e', 'f'],
      ]);
    });

    test('handles a comma inside a quoted field', () {
      final rows = decodeCsv('"Rice, Basmati",100');
      expect(rows, [
        ['Rice, Basmati', '100'],
      ]);
    });

    test('handles a newline inside a quoted field', () {
      final rows = decodeCsv('"Line1\nLine2",x');
      expect(rows, [
        ['Line1\nLine2', 'x'],
      ]);
    });

    test('unescapes doubled quotes inside a quoted field', () {
      final rows = decodeCsv('"5"" pipe",x');
      expect(rows, [
        ['5" pipe', 'x'],
      ]);
    });

    test('is the inverse of encodeCsv for plain and quoted content', () {
      final original = [
        ['name', 'note'],
        ['Rice, Basmati', 'has a "premium" tag'],
      ];
      final roundTripped = decodeCsv(encodeCsv(original));
      expect(roundTripped, original);
    });

    test('handles CRLF line endings and a trailing newline without an extra blank row', () {
      final rows = decodeCsv('a,b\r\nc,d\r\n');
      expect(rows, [
        ['a', 'b'],
        ['c', 'd'],
      ]);
    });

    test('empty input decodes to no rows', () {
      expect(decodeCsv(''), isEmpty);
    });
  });
}
