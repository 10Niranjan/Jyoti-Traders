import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/data/models/user_model.dart';
import 'package:traders_retailer/data/repositories/auth_repository_provider.dart';
import 'package:traders_retailer/data/repositories/repository_providers.dart';
import 'package:traders_retailer/domain/entities/notification_entity.dart';
import 'package:traders_retailer/domain/repositories/notification_repository.dart';
import 'package:traders_retailer/features/notifications/screens/notifications_screen.dart';
import 'package:traders_retailer/l10n/app_localizations.dart';

import '../helpers/fake_auth_repository.dart';

class FakeNotificationRepository implements NotificationRepository {
  final List<NotificationEntity> notifications;
  final List<String> markedAsRead = [];
  bool markedAllAsRead = false;

  FakeNotificationRepository(this.notifications);

  @override
  Stream<List<NotificationEntity>> watchNotifications() =>
      Stream.value(notifications);

  @override
  Future<void> addNotification(NotificationEntity notification) async {}

  @override
  Future<void> markAsRead(String id) async => markedAsRead.add(id);

  @override
  Future<void> markAllAsRead() async => markedAllAsRead = true;
}

NotificationEntity _notification({
  required String id,
  required String title,
  bool isRead = false,
  String? orderId,
}) => NotificationEntity(
  id: id,
  title: title,
  body: 'Body for $id',
  orderId: orderId,
  receivedAt: DateTime.now().subtract(const Duration(minutes: 5)),
  isRead: isRead,
);

final _retailer = UserModel(
  uid: 'u1',
  name: 'Ramesh',
  email: 'ramesh@test.com',
  phone: '9876543210',
  role: UserRole.customer,
  status: UserStatus.approved,
  businessName: 'Ramesh Kirana Store',
  createdAt: DateTime(2026, 1, 1),
);

Widget _wrap(FakeNotificationRepository repo) => ProviderScope(
  overrides: [
    notificationRepositoryProvider.overrideWithValue(repo),
    authRepositoryProvider.overrideWithValue(FakeAuthRepository(_retailer)),
  ],
  child: const MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: NotificationsScreen(),
  ),
);

void main() {
  testWidgets('shows an empty state when there are no notifications', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(FakeNotificationRepository([])));
    await tester.pumpAndSettle();

    expect(find.text('No notifications yet'), findsOneWidget);
  });

  testWidgets('lists notifications with title and body', (tester) async {
    await tester.pumpWidget(
      _wrap(
        FakeNotificationRepository([
          _notification(id: 'n1', title: 'Order confirmed'),
          _notification(id: 'n2', title: 'Order delivered', isRead: true),
        ]),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Order confirmed'), findsOneWidget);
    expect(find.text('Body for n1'), findsOneWidget);
    expect(find.text('Order delivered'), findsOneWidget);
  });

  testWidgets('shows "Mark all read" only when something is unread', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        FakeNotificationRepository([
          _notification(id: 'n1', title: 'Order confirmed', isRead: true),
        ]),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mark all read'), findsNothing);
  });

  testWidgets('tapping a notification marks it as read', (tester) async {
    final repo = FakeNotificationRepository([
      _notification(id: 'n1', title: 'Order confirmed'),
    ]);
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Order confirmed'));
    await tester.pumpAndSettle();

    expect(repo.markedAsRead, ['n1']);
  });

  testWidgets('"Mark all read" calls markAllAsRead', (tester) async {
    final repo = FakeNotificationRepository([
      _notification(id: 'n1', title: 'Order confirmed'),
    ]);
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mark all read'));
    await tester.pumpAndSettle();

    expect(repo.markedAllAsRead, isTrue);
  });
}
