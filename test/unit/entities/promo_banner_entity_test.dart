import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/data/models/promo_banner_model.dart';
import 'package:traders_retailer/domain/entities/promo_banner_entity.dart';

void main() {
  final now = DateTime(2026, 10, 20, 12);

  group('isLiveAt', () {
    test('an active banner with no end date is always live', () {
      expect(
        const PromoBannerEntity(id: 'a', title: 'x').isLiveAt(now),
        isTrue,
      );
    });

    test('a switched-off banner is never live, even before its end date', () {
      final b = PromoBannerEntity(
        id: 'a',
        title: 'x',
        isActive: false,
        endsAt: now.add(const Duration(days: 3)),
      );
      expect(b.isLiveAt(now), isFalse);
    });

    test(
      'stops being live once the end date has passed, and exactly at it',
      () {
        final b = PromoBannerEntity(id: 'a', title: 'x', endsAt: now);
        expect(b.isLiveAt(now.subtract(const Duration(seconds: 1))), isTrue);
        expect(b.isLiveAt(now), isFalse);
        expect(b.isExpiredAt(now.add(const Duration(days: 1))), isTrue);
      },
    );
  });

  test(
    'copyWith can clear the end date, which a null argument alone cannot express',
    () {
      final b = PromoBannerEntity(id: 'a', title: 'x', endsAt: now);
      expect(b.copyWith(title: 'y').endsAt, now);
      expect(b.copyWith(clearEndsAt: true).endsAt, isNull);
    },
  );

  group('PromoBannerModel', () {
    test('round-trips through the stored map', () {
      final banners = [
        PromoBannerEntity(
          id: 'a',
          title: 'Diwali kit',
          body: 'Bundle',
          endsAt: now,
        ),
        const PromoBannerEntity(id: 'b', title: 'Rice', isActive: false),
      ];
      expect(
        PromoBannerModel.listFromJson(PromoBannerModel.listToJson(banners)),
        banners,
      );
    });

    test(
      'missing or malformed data yields an empty list or safe defaults, never a crash',
      () {
        expect(PromoBannerModel.listFromJson(null), isEmpty);
        expect(PromoBannerModel.listFromJson({'items': 'oops'}), isEmpty);
        final b = PromoBannerModel.listFromJson({
          'items': [
            {'id': 'a'},
          ],
        }).single;
        expect(b.title, '');
        expect(b.isActive, isTrue);
        expect(b.endsAt, isNull);
      },
    );
  });
}
