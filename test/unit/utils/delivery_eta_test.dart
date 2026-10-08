import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/core/utils/delivery_eta.dart';

void main() {
  final morning = DateTime(2026, 1, 1, 9);
  final evening = DateTime(2026, 1, 1, 20);

  test('no coordinates yields unknown regardless of time', () {
    expect(
      estimateDeliveryEta(distanceKm: null, now: morning),
      DeliveryEta.unknown,
    );
  });

  test('within same-day radius before the cutoff hour promises today', () {
    expect(
      estimateDeliveryEta(distanceKm: 10, now: morning),
      DeliveryEta.today,
    );
  });

  test(
    'within same-day radius after the cutoff hour falls back to tomorrow',
    () {
      expect(
        estimateDeliveryEta(distanceKm: 10, now: evening),
        DeliveryEta.tomorrow,
      );
    },
  );

  test(
    'beyond same-day but within next-day radius promises tomorrow regardless of time',
    () {
      expect(
        estimateDeliveryEta(distanceKm: 30, now: morning),
        DeliveryEta.tomorrow,
      );
      expect(
        estimateDeliveryEta(distanceKm: 30, now: evening),
        DeliveryEta.tomorrow,
      );
    },
  );

  test('beyond the next-day radius promises a few days', () {
    expect(
      estimateDeliveryEta(distanceKm: 80, now: morning),
      DeliveryEta.fewDays,
    );
  });

  test('exactly at a radius boundary is still inclusive of that band', () {
    expect(
      estimateDeliveryEta(distanceKm: 15, now: morning),
      DeliveryEta.today,
    );
    expect(
      estimateDeliveryEta(distanceKm: 40, now: morning),
      DeliveryEta.tomorrow,
    );
  });
}
