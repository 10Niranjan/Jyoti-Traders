import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/core/utils/extensions.dart';
import 'package:traders_retailer/domain/entities/order_entity.dart';

void main() {
  group('String Extensions', () {
    group('capitalize', () {
      test('should capitalize first letter of string', () {
        expect('hello'.capitalize(), equals('Hello'));
        expect('WORLD'.capitalize(), equals('WORLD'));
        expect(''.capitalize(), equals(''));
        expect('a'.capitalize(), equals('A'));
      });
    });

    group('isBlank', () {
      test('should return true for empty or whitespace-only strings', () {
        expect(''.isBlank, isTrue);
        expect('   '.isBlank, isTrue);
        expect('\n\t'.isBlank, isTrue);
        expect('not blank'.isBlank, isFalse);
        expect('  a  '.isBlank, isFalse);
      });
    });

    group('shortId', () {
      test('should return uppercase first 8 characters of string', () {
        expect('abcdefghijkl'.shortId, equals('ABCDEFGH'));
        expect('12345'.shortId, equals('12345'));
        expect(''.shortId, equals(''));
      });
    });
  });

  group('DateTime Extensions', () {
    group('timeAgo', () {
      test('should return correct ago format', () {
        final now = DateTime.now();

        final justNow = now.subtract(const Duration(seconds: 30));
        expect(justNow.timeAgo, equals('just now'));

        final minsAgo = now.subtract(const Duration(minutes: 5));
        expect(minsAgo.timeAgo, equals('5m ago'));

        final hoursAgo = now.subtract(const Duration(hours: 3));
        expect(hoursAgo.timeAgo, equals('3h ago'));

        final daysAgo = now.subtract(const Duration(days: 4));
        expect(daysAgo.timeAgo, equals('4d ago'));

        final weeksAgo = now.subtract(const Duration(days: 15));
        expect(weeksAgo.timeAgo, equals('2w ago'));
      });
    });
  });

  group('OrderStatus Extensions', () {
    test('should return correct readable labels', () {
      expect(OrderStatus.pending.label, equals('Pending'));
      expect(OrderStatus.confirmed.label, equals('Confirmed'));
      expect(OrderStatus.outForDelivery.label, equals('Out for Delivery'));
      expect(OrderStatus.delivered.label, equals('Delivered'));
      expect(OrderStatus.cancelled.label, equals('Cancelled'));
    });
  });

  group('PaymentStatus Extensions', () {
    test('should return correct readable labels', () {
      expect(PaymentStatus.pending.label, equals('Awaiting payment'));
      expect(
        PaymentStatus.paymentClaimed.label,
        equals('Payment claimed — awaiting confirmation'),
      );
      expect(PaymentStatus.paid.label, equals('Paid'));
    });
  });

  group('List Extensions', () {
    group('chunked', () {
      test('should split list into chunks of specified size', () {
        final list = [1, 2, 3, 4, 5, 6, 7, 8];
        expect(
          list.chunked(3),
          equals([
            [1, 2, 3],
            [4, 5, 6],
            [7, 8],
          ]),
        );
        expect(
          list.chunked(10),
          equals([
            [1, 2, 3, 4, 5, 6, 7, 8],
          ]),
        );
        expect(<int>[].chunked(5), equals(<List<int>>[]));
      });
    });
  });
}
