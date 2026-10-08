import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/core/utils/notification_grouping.dart';
import 'package:traders_retailer/domain/entities/notification_entity.dart';

NotificationEntity _at(String id, DateTime time) => NotificationEntity(
  id: id,
  title: id,
  body: '',
  receivedAt: time,
  isRead: false,
);

void main() {
  // A Wednesday afternoon.
  final now = DateTime(2026, 9, 16, 15, 30);

  group('notificationDayOf', () {
    test('same calendar day is today, even earlier that morning', () {
      expect(
        notificationDayOf(DateTime(2026, 9, 16, 0, 5), now),
        NotificationDay.today,
      );
    });

    test('judges by calendar day, not by 24 hours', () {
      // 12:05 a.m. — a notification from 11:55 p.m. is "yesterday", 10 minutes old.
      final justAfterMidnight = DateTime(2026, 9, 16, 0, 5);
      expect(
        notificationDayOf(DateTime(2026, 9, 15, 23, 55), justAfterMidnight),
        NotificationDay.yesterday,
      );
    });

    test('2 to 6 days back is this week, 7+ is earlier', () {
      expect(
        notificationDayOf(DateTime(2026, 9, 14, 9), now),
        NotificationDay.thisWeek,
      );
      expect(
        notificationDayOf(DateTime(2026, 9, 10, 9), now),
        NotificationDay.thisWeek,
      );
      expect(
        notificationDayOf(DateTime(2026, 9, 9, 9), now),
        NotificationDay.earlier,
      );
    });

    test('a timestamp slightly in the future still counts as today', () {
      expect(
        notificationDayOf(DateTime(2026, 9, 16, 23), now),
        NotificationDay.today,
      );
    });
  });

  group('groupNotificationsByDay', () {
    test('buckets in display order, keeping newest-first within each', () {
      final groups = groupNotificationsByDay([
        _at('a', DateTime(2026, 9, 16, 14)),
        _at('b', DateTime(2026, 9, 16, 9)),
        _at('c', DateTime(2026, 9, 15, 20)),
        _at('d', DateTime(2026, 8, 1)),
      ], now: now);

      expect(groups.map((g) => g.day), [
        NotificationDay.today,
        NotificationDay.yesterday,
        NotificationDay.earlier,
      ]);
      expect(groups[0].items.map((n) => n.id), ['a', 'b']);
    });

    test('drops empty buckets and handles an empty list', () {
      expect(groupNotificationsByDay(const [], now: now), isEmpty);
    });
  });

  group('NotificationEntity.displayKind', () {
    test('an order id makes an unlabelled notification an order update', () {
      final legacy = NotificationEntity(
        id: 'x',
        title: 't',
        body: 'b',
        orderId: 'o1',
        receivedAt: now,
        isRead: false,
      );
      expect(legacy.displayKind, NotificationKind.order);
    });

    test('an explicit kind wins over the order-id fallback', () {
      final stock = NotificationEntity(
        id: 'x',
        title: 't',
        body: 'b',
        orderId: 'o1',
        receivedAt: now,
        isRead: false,
        kind: NotificationKind.stock,
      );
      expect(stock.displayKind, NotificationKind.stock);
    });
  });
}
