import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/domain/value_objects/money.dart';

void main() {
  group('Money', () {
    test('formats as Indian Rupees', () {
      expect(Money(2500).formatted, '₹2,500');
    });

    test('throws when constructed with a negative amount', () {
      expect(() => Money(-1), throwsArgumentError);
    });

    test('addition combines two amounts', () {
      expect((Money(1000) + Money(500)).amount, 1500);
    });

    test('supports value equality', () {
      expect(Money(2500), Money(2500));
    });

    test('>= compares amounts', () {
      expect(Money(2500) >= Money(2500), isTrue);
      expect(Money(2000) >= Money(2500), isFalse);
    });
  });
}
