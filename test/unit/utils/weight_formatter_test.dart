import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/core/utils/weight_formatter.dart';

void main() {
  group('Weight Formatter Utils', () {
    group('weightStepFor', () {
      test('under 1000 grams should return 100g step', () {
        expect(weightStepFor(0), equals(100));
        expect(weightStepFor(500), equals(100));
        expect(weightStepFor(999), equals(100));
      });

      test('between 1000 and 4999 grams should return 500g step', () {
        expect(weightStepFor(1000), equals(500));
        expect(weightStepFor(2500), equals(500));
        expect(weightStepFor(4999), equals(500));
      });

      test('5000 grams and above should return 1000g step', () {
        expect(weightStepFor(5000), equals(1000));
        expect(weightStepFor(10000), equals(1000));
      });
    });

    group('defaultAddGrams', () {
      test('under 1000 grams should return maxGrams', () {
        expect(defaultAddGrams(250), equals(250));
        expect(defaultAddGrams(999), equals(999));
      });

      test('1000 grams and above should return 1000', () {
        expect(defaultAddGrams(1000), equals(1000));
        expect(defaultAddGrams(5000), equals(1000));
      });
    });

    group('formatGrams', () {
      test('under 1000 grams format as grams', () {
        expect(formatGrams(250), equals('250 g'));
        expect(formatGrams(500), equals('500 g'));
        expect(formatGrams(999), equals('999 g'));
      });

      test('above 1000 grams formats as kg and trims trailing zeros', () {
        expect(formatGrams(1000), equals('1 kg'));
        expect(formatGrams(2500), equals('2.5 kg'));
        expect(formatGrams(2250), equals('2.25 kg'));
        expect(formatGrams(12750), equals('12.75 kg'));
        expect(formatGrams(3005), equals('3.005 kg'));
      });
    });
  });
}
