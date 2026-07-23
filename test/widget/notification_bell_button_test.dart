import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/data/repositories/repository_providers.dart';
import 'package:traders_retailer/domain/entities/notification_entity.dart';
import 'package:traders_retailer/domain/repositories/notification_repository.dart';
import 'package:traders_retailer/shared/widgets/notification_bell_button.dart';

class FakeNotificationRepository implements NotificationRepository {
  final List<NotificationEntity> notifications;
  FakeNotificationRepository(this.notifications);

  @override
  Stream<List<NotificationEntity>> watchNotifications() => Stream.value(notifications);

  @override
  Future<void> addNotification(NotificationEntity notification) async {}

  @override
  Future<void> markAsRead(String id) async {}

  @override
  Future<void> markAllAsRead() async {}
}

NotificationEntity _notification(String id, {bool isRead = false}) => NotificationEntity(
      id: id,
      title: 'Title $id',
      body: 'Body $id',
      receivedAt: DateTime.now(),
      isRead: isRead,
    );

Widget _wrap(FakeNotificationRepository repo) => ProviderScope(
      overrides: [notificationRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(home: Scaffold(appBar: AppBar(actions: const [NotificationBellButton()]))),
    );

void main() {
  testWidgets('hides the badge when there are no unread notifications', (tester) async {
    await tester.pumpWidget(_wrap(FakeNotificationRepository([_notification('n1', isRead: true)])));
    await tester.pumpAndSettle();

    expect(find.text('1'), findsNothing);
  });

  testWidgets('shows the unread count on the badge', (tester) async {
    await tester.pumpWidget(_wrap(FakeNotificationRepository([
      _notification('n1'),
      _notification('n2'),
      _notification('n3', isRead: true),
    ])));
    await tester.pumpAndSettle();

    expect(find.text('2'), findsOneWidget);
  });
}
