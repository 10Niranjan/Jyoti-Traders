import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/core/utils/validators.dart';

void main() {
  group('Validators.name', () {
    test('rejects digits', () {
      expect(Validators.name('John3'), isNotNull);
    });
    test('accepts letters, spaces, apostrophes and hyphens', () {
      expect(Validators.name("Mary-Jane O'Neil"), isNull);
    });
    test('rejects empty', () {
      expect(Validators.name(''), isNotNull);
    });
    test('rejects a single character', () {
      expect(Validators.name('A'), isNotNull);
    });
    test('rejects doubled-up spaces', () {
      expect(Validators.name('John  Doe'), isNotNull);
    });
    test('rejects over 50 characters', () {
      expect(Validators.name('A' * 51), isNotNull);
    });
  });

  group('Validators.businessName', () {
    test('accepts digits — shop names like "Shop No. 24" are common', () {
      expect(Validators.businessName('Shop 24'), isNull);
    });
    test('accepts letters, numbers, spaces, & - .', () {
      expect(Validators.businessName('Patil & Sons - Kirana Mart'), isNull);
    });
    test('rejects empty', () {
      expect(Validators.businessName(''), isNotNull);
    });
    test('rejects a single character', () {
      expect(Validators.businessName('A'), isNotNull);
    });
    test('rejects emoji/unsupported symbols', () {
      expect(Validators.businessName('Shop 😀'), isNotNull);
    });
  });

  group('Validators.phone', () {
    test('rejects fewer than 10 digits', () {
      expect(Validators.phone('98765'), isNotNull);
    });
    test('rejects more than 10 digits', () {
      expect(Validators.phone('987654321012'), isNotNull);
    });
    test('rejects a number not starting with 6-9', () {
      expect(Validators.phone('1234567890'), isNotNull);
    });
    test('accepts a valid 10-digit Indian mobile number', () {
      expect(Validators.phone('9876543210'), isNull);
    });
  });

  group('Validators.email', () {
    test('rejects missing @', () {
      expect(Validators.email('not-an-email'), isNotNull);
    });
    test('accepts an address with digits in the local part', () {
      expect(Validators.email('owner123@shop.com'), isNull);
    });
    test('rejects empty', () {
      expect(Validators.email(''), isNotNull);
    });
    test('rejects over 254 characters', () {
      expect(Validators.email('${'a' * 250}@a.com'), isNotNull);
    });
  });

  group('Validators.password', () {
    test('rejects fewer than 8 characters', () {
      expect(Validators.password('Ab1!ab'), isNotNull);
    });
    test('rejects missing uppercase', () {
      expect(Validators.password('niranjan@123'), isNotNull);
    });
    test('rejects missing lowercase', () {
      expect(Validators.password('NIRANJAN@123'), isNotNull);
    });
    test('rejects missing a digit', () {
      expect(Validators.password('Niranjan@abc'), isNotNull);
    });
    test('rejects missing a special character', () {
      expect(Validators.password('Niranjan123'), isNotNull);
    });
    test('rejects leading/trailing spaces', () {
      expect(Validators.password(' Niranjan@123'), isNotNull);
    });
    test('accepts a password meeting every rule', () {
      expect(Validators.password('Niranjan@123'), isNull);
    });
  });
}
