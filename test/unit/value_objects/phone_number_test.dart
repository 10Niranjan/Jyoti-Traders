import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/domain/value_objects/phone_number.dart';

void main() {
  group('PhoneNumber', () {
    test('accepts a valid 10-digit Indian mobile number', () {
      expect(PhoneNumber('9860460325').value, '9860460325');
    });

    test('rejects a number starting with 0-5', () {
      expect(() => PhoneNumber('5860460325'), throwsArgumentError);
    });

    test('rejects a number with fewer than 10 digits', () {
      expect(() => PhoneNumber('98604603'), throwsArgumentError);
    });

    test('rejects non-numeric input', () {
      expect(() => PhoneNumber('98604abcde'), throwsArgumentError);
    });
  });
}
