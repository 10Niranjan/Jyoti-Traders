import '../../domain/entities/notification_entity.dart';

/// The inbox's day buckets, in the order they are shown.
enum NotificationDay { today, yesterday, thisWeek, earlier }

/// Which bucket a notification received at [time] falls in, judged by
/// calendar day (not a rolling 24h) so "Yesterday" means what people expect
/// at 12:05 a.m.
NotificationDay notificationDayOf(DateTime time, DateTime now) {
  // UTC midnights, so a daylight-saving shift can't turn a day into 23h and
  // make `inDays` round down to the wrong bucket.
  final today = DateTime.utc(now.year, now.month, now.day);
  final day = DateTime.utc(time.year, time.month, time.day);
  final age = today.difference(day).inDays;
  if (age <= 0) return NotificationDay.today;
  if (age == 1) return NotificationDay.yesterday;
  if (age < 7) return NotificationDay.thisWeek;
  return NotificationDay.earlier;
}

/// Splits [items] (already newest-first) into day buckets, keeping each
/// bucket's order and dropping empty ones. [now] is injectable for tests.
List<({NotificationDay day, List<NotificationEntity> items})>
groupNotificationsByDay(List<NotificationEntity> items, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final buckets = <NotificationDay, List<NotificationEntity>>{};
  for (final item in items) {
    buckets
        .putIfAbsent(
          notificationDayOf(item.receivedAt, reference),
          () => <NotificationEntity>[],
        )
        .add(item);
  }
  return [
    for (final day in NotificationDay.values)
      if (buckets[day] != null) (day: day, items: buckets[day]!),
  ];
}
